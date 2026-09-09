package Luv::CLI::Command::Build;
use v5.38;
use Object::Pad;

use App::Cmd::Setup -command;

sub abstract {
    "Packages the project into a .love file."
}

1;