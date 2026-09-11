package Luv::CLI::Command::Search;

# ABSTRACT: search the library registry

use v5.38;

use App::Cmd::Setup -command;
use File::HomeDir;

use Luv::CLI::Registry;

sub abstract {"Searches the local library registry."}

sub opt_spec {
    return (
        [ 'update' => 'refresh the registry before searching' ],
        [ 'all|a'  => 'list all libraries in the local registry cache' ],
    );
}

sub execute ( $self, $opt, $args ) {
    my $cache_path = File::HomeDir->my_home . '/.cache/luv/registry.json';
    my $registry   = Luv::CLI::Registry->new( cache_path => $cache_path );

    if ( $opt->{update} || $registry->is_stale ) {
        print "Refreshing registry...\n";
        $registry->refresh;
    }
    else {
        $registry->load;
    }

    my @matches;
    if ( $opt->{all} ) {
        @matches = $registry->all_entries;
    }
    else {
        my $term = $args->[0] or die "Usage: luv search <term> | --all\n";
        @matches = $registry->search($term);
    }

    if ( !@matches ) {
        print "No libraries found\n";
        return;
    }

    for my $m ( sort { ( $a->{name} // '' ) cmp ( $b->{name} // '' ) }
        @matches )
    {
        my $name = $m->{name} // '(unknown)';
        print "$name — $m->{description}\n  $m->{url}\n\n";
    }

    return;
}

1;

=head1 NAME

Luv::CLI::Command::Search - search the library registry

=head1 SYNOPSIS

    luv search input
    luv search physics --update

=head1 DESCRIPTION

Searches the local registry cache for libraries matching the given
term, by name or description. Refreshes the cache first if it's stale
or if C<--update> is given.

=head1 AUTHOR

Nobunaga <nobunaga@cpan.org>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
