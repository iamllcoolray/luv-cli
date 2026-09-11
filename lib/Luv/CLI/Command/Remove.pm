package Luv::CLI::Command::Remove;

# ABSTRACT: remove a library dependency

use v5.38;
use Object::Pad;

use App::Cmd::Setup -command;
use File::Path qw(remove_tree);

use Luv::CLI::Manifest;

sub abstract {
    "Removes a library dependency.";
}

sub opt_spec {
    return ( [ 'all|a' => 'remove all dependencies' ], );
}

sub execute ( $self, $opt, $args ) {
    my $manifest_path = "luv.json";
    die "No luv.json found — run 'luv init' first\n" unless -e $manifest_path;

    my $manifest = Luv::CLI::Manifest->new( path => $manifest_path );
    $manifest->load;

    if ( $opt->{all} ) {
        my $deps  = $manifest->dependencies;
        my $count = scalar keys %$deps;

        for my $key ( keys %$deps ) {
            File::Path::remove_tree( $deps->{$key}{path} )
                if -d $deps->{$key}{path};
        }

        $manifest->clear_dependencies;
        $manifest->save;
        print "Removed all $count dependencies\n";
        return;
    }

    die "Usage: luv remove <library-name> [...] | --all\n" unless @$args;

    for my $name (@$args) {
        unless ( $manifest->has_dependency($name) ) {
            warn "No such dependency: $name — skipping\n";
            next;
        }

        my $dep = $manifest->dependencies->{ lc $name };
        File::Path::remove_tree( $dep->{path} ) if -d $dep->{path};
        $manifest->remove_dependency($name);

        my $display_name = $dep->{name} // $name;
        print "Removed '$display_name'\n";
    }

    $manifest->save;
    return;
}

1;

=head1 NAME

Luv::CLI::Command::Remove - remove a library dependency

=head1 SYNOPSIS

    luv remove baton

=head1 DESCRIPTION

Deletes the vendored directory for the named dependency and removes
its entry from C<luv.json>.

=head1 AUTHOR

Nobunaga <nobunaga@cpan.org>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
