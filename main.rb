#!/usr/bin/env jruby

lib_dir = File.dirname(__FILE__) + '/lib'
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

require 'command_line'
require 'main'
require 'base'
require 'friend'
require 'user'

FriendFinder::Main.execute
