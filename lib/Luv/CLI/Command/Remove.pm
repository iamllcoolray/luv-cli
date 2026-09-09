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

sub execute ( $self, $opt, $args ) {
    my $name = $args->[0] or die "Usage: luv remove <library-name>\n";

    my $manifest_path = "luv.json";
    die "No luv.json found — run 'luv init' first\n" unless -e $manifest_path;

    my $manifest = Luv::CLI::Manifest->new( path => $manifest_path );
    $manifest->load;

    die "No such dependency: $name\n"
        unless $manifest->has_dependency( lc $name );

    my $dep = $manifest->dependencies->{ lc $name };
    File::Path::remove_tree( $dep->{path} ) if -d $dep->{path};

    $manifest->remove_dependency( lc $name );
    $manifest->save;

    print "Removed '$name'\n";
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
