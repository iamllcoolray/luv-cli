package Luv::CLI::Command::Search;
use v5.38;

use App::Cmd::Setup -command;
use File::HomeDir;

use Luv::CLI::Registry;

sub abstract {"Searches the local library registry."}

sub opt_spec {
    return ( [ 'update' => 'refresh the registry before searching' ], );
}

sub execute ( $self, $opt, $args ) {
    my $term       = $args->[0] or die "Usage: luv search <term>\n";
    my $cache_path = File::HomeDir->my_home . '/.cache/luv/registry.json';
    my $registry   = Luv::CLI::Registry->new( cache_path => $cache_path );

    if ( $opt->{update} || $registry->is_stale ) {
        print "Refreshing registry...\n";
        $registry->refresh;
    }
    else {
        $registry->load;
    }

    my @matches = $registry->search($term);

    if ( !@matches ) {
        print "No libraries found matching '$term'\n";
        return;
    }

    for my $m (@matches) {
        print "$m->{name} — $m->{description}\n  $m->{url}\n\n";
    }
    return;
}

1;
