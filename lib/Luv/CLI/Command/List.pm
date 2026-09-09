package Luv::CLI::Command::List;
use v5.38;
use Object::Pad;

use App::Cmd::Setup -command;

sub abstract {
    "Lists the current dependencies."
}

1;