use v5.38;
use Object::Pad;

use JSON::PP;
use File::Path qw(make_path);

class Luv::CLI::Registry;

field $cache_path :param;
field %entries;

method cache_path () { return $cache_path; }

method load () {
    return unless -e $cache_path;
    open my $fh, '<', $cache_path or die "Cannot read $cache_path: $!\n";
    local $/;
    my $data = JSON::PP->new->utf8->decode(<$fh>);
    close $fh;
    %entries = %{ $data->{entries} // {} };
    return;
}

method save () {
    make_path($self->cache_dir);
    open my $fh, '>', $cache_path or die "Cannot write $cache_path: $!\n";
    print { $fh } JSON::PP->new->utf8->canonical->pretty->encode({
        updated_at => time,
        entries    => \%entries,
    });
    close $fh;
    return;
}

method cache_dir () {
    my ($dir) = $cache_path =~ m{^(.*)/[^/]+$};
    return $dir;
}

method is_stale ($max_age_seconds = 86400 * 7) {
    return 1 unless -e $cache_path;
    return (time - (stat($cache_path))[9]) > $max_age_seconds;
}

method add_entry ($name, %info) {
    $entries{$name} = {
        url         => $info{url},
        category    => $info{category},
        description => $info{description},
    };
    return;
}

method search ($term) {
    my @matches;
    for my $name (keys %entries) {
        push @matches, { name => $name, %{ $entries{$name} } }
            if $name =~ /\Q$term\E/i
            || ($entries{$name}{description} // '') =~ /\Q$term\E/i;
    }
    return @matches;
}

method find ($name) {
    return $entries{$name};
}

method parse_readme ($markdown) {
    my $category = 'Uncategorized';

    for my $line (split /\n/, $markdown) {
        if ($line =~ /^##\s+(.+)/) {
            $category = $1;
            next;
        }

        if ($line =~ /^\s*-\s*\[([^\]]+)\]\(([^)]+)\)\s*-\s*(.+)/) {
            my ($name, $url, $description) = ($1, $2, $3);
            $self->add_entry($name, url => $url, category => $category, description => $description);
        }
    }

    return;
}

method refresh () {
    my $readme_url = 'https://raw.githubusercontent.com/love2d-community/awesome-love2d/master/README.md';

    require IPC::Run;
    my ($out, $err);
    IPC::Run::run(['curl', '-sL', $readme_url], \undef, \$out, \$err)
        or die "Failed to fetch awesome-love2d README:\n$err";

    %entries = ();
    $self->parse_readme($out);
    $self->save;

    return scalar keys %entries;
}

1;