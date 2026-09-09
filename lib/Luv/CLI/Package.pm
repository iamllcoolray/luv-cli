use v5.38;
use Object::Pad;

use Archive::Zip qw(:ERROR_CODES);
use File::Find;

class Luv::CLI::Package;

field $manifest : param;

method build () {
    my $output_path = $manifest->build_dir . '/' . $manifest->output_name;

    my $zip = Archive::Zip->new;

    for my $file ( 'main.lua', 'conf.lua' ) {
        if ( -f $file ) {
            $zip->addFile( $file, $file );
        }
    }

    $self->add_dir( $zip, $manifest->source_dir,  '' );
    $self->add_dir( $zip, $manifest->library_dir, $manifest->library_dir );
    $self->add_dir( $zip, $manifest->assets_dir,  $manifest->assets_dir );

    File::Path::make_path( $manifest->build_dir )
        unless -d $manifest->build_dir;

    unless ( $zip->writeToFileNamed($output_path) == Archive::Zip::AZ_OK() ) {
        die "Failed to write $output_path\n";
    }

    return $output_path;
}

method add_dir ( $zip, $dir, $zip_prefix ) {
    return unless -d $dir;

    my $build_dir = $manifest->build_dir;

    File::Find::find(
        {   wanted => sub {
                return unless -f $_;
                my $rel = $File::Find::name;

                return if $rel =~ m{^\Q$build_dir\E(/|$)};

                $rel =~ s{^\Q$dir\E/?}{};
                my $zip_path = $zip_prefix ? "$zip_prefix/$rel" : $rel;
                $zip->addFile( $_, $zip_path );
            },
            no_chdir => 1,
        },
        $dir
    );

    return;
}

1;
