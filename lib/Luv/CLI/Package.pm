use v5.38;
use Object::Pad;

use Archive::Zip qw(:ERROR_CODES);
use File::Find;

class Luv::CLI::Package;

field $manifest :param;

method build () {
    my $output_path = $manifest->build_dir . '/' . $manifest->output_name;

    my $zip = Archive::Zip->new;

    $self->add_dir($zip, $manifest->source_dir, '');
    $self->add_dir($zip, $manifest->library_dir, $manifest->library_dir);
    $self->add_dir($zip, $manifest->assets_dir, $manifest->assets_dir);

    unless ($zip->writeToFileNamed($output_path) == Archive::Zip::AZ_OK()) {
        die "Failed to write $output_path\n";
    }

    return $output_path;
}

method add_dir ($zip, $dir, $zip_prefix) {
    return unless -d $dir;

    find({
        wanted => sub {
            return unless -f $_;
            my $rel = $File::Find::name;
            $rel =~ s{^\Q$dir\E/?}{};
            my $zip_path = $zip_prefix ? "$zip_prefix/$rel" : $rel;
            $zip->addFile($_, $zip_path);
        },
        no_chdir => 1,
    }, $dir);

    return;
}

1;