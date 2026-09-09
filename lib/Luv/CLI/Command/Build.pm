package Luv::CLI::Command::Build;
use v5.38;
use Object::Pad;

use App::Cmd::Setup -command;

use Luv::CLI::Manifest;
use Luv::CLI::Package;

sub abstract {
    "Packages the project into a .love file.";
}

sub execute ( $self, $opt, $args ) {
    my $manifest_path = "luv.json";
    die "No luv.json found — run 'luv init' first\n" unless -e $manifest_path;

    my $manifest = Luv::CLI::Manifest->new( path => $manifest_path );
    $manifest->load;

    my $package     = Luv::CLI::Package->new( manifest => $manifest );
    my $output_path = $package->build;

    print "Built $output_path\n";
    return;
}

1;
