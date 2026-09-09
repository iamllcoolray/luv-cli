package Luv::CLI::Command::Add;
use v5.38;
use Object::Pad;

use App::Cmd::Setup -command;
use File::HomeDir;

use Luv::CLI::Manifest;
use Luv::CLI::Git;
use Luv::CLI::Registry;

sub abstract {
    "Adds a library dependency from a git repo.";
}

sub opt_spec {
    return ( [ 'ref=s' => 'git ref (branch/tag/commit) to check out' ], );
}

sub execute ( $self, $opt, $args ) {
    my $target = $args->[0] or die "Usage: luv add <repo-url|library-name>\n";

    my $manifest_path = "luv.json";
    die "No luv.json found — run 'luv init' first\n" unless -e $manifest_path;

    my $manifest = Luv::CLI::Manifest->new( path => $manifest_path );
    $manifest->load;

    my ( $name, $url );

    if ( $target =~ m{^https?://} || $target =~ m{^git\@} ) {
        $url = $target;
        ($name) = $url =~ m{([^/]+?)(?:\.git)?/?$};
    }
    else {
        my $cache_path = File::HomeDir->my_home . '/.cache/luv/registry.json';
        my $registry   = Luv::CLI::Registry->new( cache_path => $cache_path );
        $registry->load;

        my $entry = $registry->find($target);
        die
            "Library '$target' not found in registry — try 'luv search $target' or pass a git URL\n"
            unless $entry;

        $name = $target;
        $url  = $entry->{url};
    }

    die "Dependency '$name' already exists\n"
        if $manifest->has_dependency($name);

    my $dest = $manifest->library_dir . "/$name";
    my $git  = Luv::CLI::Git->new;
    $git->clone( $url, $dest, $opt->{ref} );

    $manifest->add_dependency(
        $name,
        url  => $url,
        ref  => $opt->{ref} // 'main',
        path => $dest
    );
    $manifest->save;

    print "Added '$name' from $url\n";
    return;
}

1;
