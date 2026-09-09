package Luv::CLI::Command::Add;
use v5.38;
use Object::Pad;

use App::Cmd::Setup -command;

sub abstract {
    "Adds a library dependency from a git repo."
}

1;