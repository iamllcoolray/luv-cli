use v5.38;
use Object::Pad;
use JSON::PP;

class Luv::CLI::Manifest;

field $path         : param;
field $project_name : param = "untitled";
field $output_name  : param = undef;
field $source_dir   : param = "src";
field $library_dir  : param = "lib";
field $assets_dir   : param = "assets";
field $build_dir    : param = "build";
field %dependencies;

ADJUST {
    $output_name //= "$project_name.love";
}

method add_dependency( $name, %info ) {
    die "Dependency '$name' already exits.\n"
        if exists $dependencies{ lc $name };

    $dependencies{$name} = {
        url  => $info{url},
        ref  => $info{ref}  // "main",
        path => $info{path} // "$library_dir/$name"
    };

    return;
}

method remove_dependency($name) {
    die "No such dependency: $name" unless exists $dependencies{$name};

    delete $dependencies{$name};

    return;
}

method has_dependency($name) {
    return exists $dependencies{$name};
}

method dependencies() {
    return \%dependencies;
}

method project_name() {
    return $project_name;
}

method source_dir() {
    return $source_dir;
}

method library_dir() {
    return $library_dir;
}

method assets_dir() {
    return $assets_dir;
}

method build_dir() {
    return $build_dir;
}

method output_name() {
    return $output_name;
}

method path() {
    return $path;
}

method to_hash() {
    return {
        project_name => $project_name,
        output_name  => $output_name,
        source_dir   => $source_dir,
        library_dir  => $library_dir,
        assets_dir   => $assets_dir,
        build_dir    => $build_dir,
        dependencies => \%dependencies,
    };
}

method save() {
    open my $fh, '>', $path or die "Cannot write to $path: $!.\n";
    print {$fh}
        JSON::PP->new->utf8->canonical->pretty->encode( $self->to_hash );
    close $fh;

    return;
}

method load() {
    open my $fh, '<', $path or die "Cannot read from $path: $!\n";
    local $/;
    my $data = JSON::PP->new->utf8->decode(<$fh>);
    close $fh;

    $project_name = $data->{project_name} // $project_name;
    $output_name  = $data->{output_name}  // $output_name;
    $source_dir   = $data->{source_dir}   // $source_dir;
    $library_dir  = $data->{library_dir}  // $library_dir;
    $assets_dir   = $data->{assets_dir}   // $assets_dir;
    $build_dir    = $data->{build_dir}    // $build_dir;
    %dependencies = %{ $data->{dependencies} // {} };

    return;
}

method exists_on_disk() {
    return -e $path;
}

1;
