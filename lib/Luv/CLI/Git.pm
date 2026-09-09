use v5.38;
use Object::Pad;

use IPC::Run qw(run);

class Luv::CLI::Git;

method clone ( $url, $dest, $ref = undef ) {
    my @cmd = ( 'git', 'clone', $url, $dest );
    my ( $out, $err );
    IPC::Run::run( \@cmd, \undef, \$out, \$err )
        or die "git clone failed for '$url':\n$err";

    if ( defined $ref ) {
        $self->checkout( $dest, $ref );
    }

    return 1;
}

method checkout ( $dest, $ref ) {
    my @cmd = ( 'git', '-C', $dest, 'checkout', $ref );
    my ( $out, $err );
    IPC::Run::run( \@cmd, \undef, \$out, \$err )
        or die "git checkout '$ref' failed in '$dest':\n$err";

    return 1;
}

method pull ($dest) {
    my @cmd = ( 'git', '-C', $dest, 'pull' );
    my ( $out, $err );
    IPC::Run::run( \@cmd, \undef, \$out, \$err )
        or die "git pull failed in '$dest':\n$err";

    return 1;
}

method current_ref ($dest) {
    my @cmd = ( 'git', '-C', $dest, 'rev-parse', 'HEAD' );
    my ( $out, $err );
    IPC::Run::run( \@cmd, \undef, \$out, \$err )
        or die "git rev-parse failed in '$dest':\n$err";

    chomp $out;
    return $out;
}

1;
