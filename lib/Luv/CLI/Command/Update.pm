package Luv::CLI::Command::Update;
use v5.38;

use App::Cmd::Setup -command;
use File::HomeDir;

use Luv::CLI::Registry;

sub abstract { "Refreshes the local library registry cache." }

sub execute ($self, $opt, $args) {
    my $cache_path = File::HomeDir->my_home . '/.cache/luv/registry.json';
    my $registry = Luv::CLI::Registry->new(cache_path => $cache_path);

    my $count = $registry->refresh;
    print "Registry updated: $count libraries indexed\n";
    return;
}

1;