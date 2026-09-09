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

=head1 NAME

Luv::CLI::Command::List - list current dependencies

=head1 SYNOPSIS

    luv list

=head1 DESCRIPTION

Reads C<luv.json> and prints each dependency's name, URL, ref, and
local path. Read-only; makes no changes to the project.

=head1 AUTHOR

Nobunaga <nobunaga@cpan.org>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
