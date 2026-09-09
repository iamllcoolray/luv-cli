package Luv::CLI::Command::List;
use v5.38;
use Object::Pad;

use App::Cmd::Setup -command;

use Luv::CLI::Manifest;

sub abstract {
    "Lists the current dependencies.";
}

sub execute ( $self, $opt, $args ) {
    my $manifest_path = "luv.json";
    die "No luv.json found — run 'luv init' first\n" unless -e $manifest_path;

    my $manifest = Luv::CLI::Manifest->new( path => $manifest_path );
    $manifest->load;

    my $deps = $manifest->dependencies;

    unless (%$deps) {
        print "No dependencies\n";
        return;
    }

    for my $key ( sort keys %$deps ) {
        my $dep  = $deps->{$key};
        my $name = $dep->{name} // $key;
        print "$name\n";
        print "  url:  $dep->{url}\n";
        print "  ref:  $dep->{ref}\n";
        print "  path: $dep->{path}\n";
    }

    return;
}

1;
