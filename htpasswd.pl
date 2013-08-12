#!/usr/bin/perl -wT
#
#

BEGIN {
# make the environment safe
  delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};
  $ENV{PATH} = "";
}

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Apache::Htpasswd;
my $cgi = new CGI;
$|++;

my %settings = (title    => "htpasswd edition page",
                dir      => "/etc/apache2/",
                htpasswd => "htpasswd",
                fields   => [ "rm_user", "new_user", "new_user_passwd", "new_user_passwd2" , "old_passwd", "new_passwd", "new_passwd2" ],
               );
$settings{user} = $ENV{REMOTE_USER};

my $htpasswd = new Apache::Htpasswd("$settings{dir}/$settings{htpasswd}");

print_page_headers($settings{title});
process_form();
print_form();

exit;

sub process_form {

  return unless ( $cgi->param('change') or $cgi->param('add') or $cgi->param('del') );

  my %data;
  for my $field ($cgi->param()){
    if ( scalar grep /^\Q$field\E$/, @{$settings{fields}} ){
      # its a field we know about
      my $tmp = substr($cgi->param($field), 0, 50);
      $tmp = lc($tmp) if ( $field eq "change_user_name" );
      $data{$field} = $tmp || '';
    }
  }

  if ( $cgi->param('del') ){
    if ( (!$data{rm_user}) ){
      print $cgi->p("You must fill out all fields of one of the forms!");
      return;
    }


    $htpasswd->htDelete($data{rm_user});
    if ( my $error = $htpasswd->error() ){
      print $cgi->p("There was en error: [$error]");
    }
    else {
      print $cgi->p("User $data{rm_user} was succesfully removed");
    }
  }

  if ( $cgi->param('add') ){
    if ( (!$data{new_user} or !$data{new_user_passwd} or !$data{new_user_passwd2}) ){
      print $cgi->p("You must fill out all fields of one of the forms!");
      return;
    }

    if ( $data{new_passwd} ne $data{new_passwd2} ){
      print $cgi->p("New passwords don't match!");
      return;
    }

    $htpasswd->htpasswd($data{new_user}, $data{new_user_passwd});
    if ( my $error = $htpasswd->error() ){
      print $cgi->p("There was en error: [$error]");
    }
    else {
      print $cgi->p("User $data{new_user} was succesfully added");
    }
  }

  if ( $cgi->param('change') ){
    if ( (!$data{old_passwd} or !$data{new_passwd} or !$data{new_passwd2})  ){
      print $cgi->p("You must fill out all fields of one of the forms!");
      return;
    }
#and (!$data{new_user} or !$data{new_user_passwd} or !$data{new_user_passwd2})

    if ( ! $htpasswd->htCheckPassword($settings{user}, $data{old_passwd}) ){
      print $cgi->p("Old password incorrect or invalid user name");
      return;
    }
  
    if ( $data{new_passwd} eq $data{old_passwd} ){
      print $cgi->p("New password must be different to old password!");
      return;
    }
  
    if ( $data{new_passwd} ne $data{new_passwd2} ){
      print $cgi->p("New passwords don't match!");
      return;
    }
  
    $htpasswd->htpasswd($settings{user}, $data{new_passwd}, $data{old_passwd});
    if ( my $error = $htpasswd->error() ){
      print $cgi->p("There was en error: [$error]");
    }
    else {
      print $cgi->p("Password for $settings{user} was succesfully changed");
    }
  }
}

sub print_page_headers {
  my $title = shift || "Page without a title";
  print $cgi->header();
  print $cgi->start_html($title);
  print $cgi->h2($title);
  print $cgi->hr();
  return;
}

sub print_form {
 
  for (@{$settings{fields}} ){
    $cgi->delete($_);
  } 
 
  print $cgi->start_form();
  print $cgi->b("Adding new user");
  print $cgi->table({-border=>0},
  $cgi->Tr(
  $cgi->td("Enter the ", $cgi->strong("new"), " user login"),
  $cgi->td($cgi->textfield( -name      => 'new_user',
                                 -value     => '',
                                 -size      => 10,
                                 -maxlength => 8))),
  $cgi->Tr($cgi->td("Enter the ", $cgi->strong("new"), " password"),
  $cgi->td($cgi->password_field( -name      => 'new_user_passwd',
                                 -value     => '',
                                 -size      => 10,
                                 -maxlength => 10))),
  $cgi->Tr($cgi->td("Re-Enter the new password"),
  $cgi->td($cgi->password_field( -name      => 'new_user_passwd2',
                                 -value     => '',
                                 -size      => 10,
                                 -maxlength => 10)),
  $cgi->td($cgi->submit( -name  => 'add',
                         -value => 'Add User'))),
  );

  print $cgi->end_form(), $cgi->hr();
  print $cgi->start_form();
  print $cgi->b("Delete user");#$settings{user}:");
  print $cgi->table({-border=>0},
  $cgi->Tr(
  $cgi->td("Enter the user's login to ", $cgi->strong("remove")),
  $cgi->td($cgi->textfield( -name      => 'rm_user',
                                 -value     => '',
                                 -size      => 10,
                                 -maxlength => 8)),
  $cgi->td($cgi->submit( -name  => 'del',
                         -value => 'Delete user'))),
  );
  print $cgi->end_form(), $cgi->hr();

  print $cgi->start_form();
  print $cgi->b("Password Change for $settings{user}:");
  print $cgi->table({-border=>0},
  $cgi->Tr(
  $cgi->td("Enter your ", $cgi->strong("old"), " password"),
  $cgi->td($cgi->password_field( -name      => 'old_passwd',
                                 -value     => '',
                                 -size      => 10,
                                 -maxlength => 8))),
  $cgi->Tr($cgi->td("Enter your ", $cgi->strong("new"), " password"),
  $cgi->td($cgi->password_field( -name      => 'new_passwd',
                                 -value     => '',
                                 -size      => 10,
                                 -maxlength => 10))),
  $cgi->Tr($cgi->td("Re-Enter your new password"),
  $cgi->td($cgi->password_field( -name      => 'new_passwd2',
                                 -value     => '',
                                 -size      => 10,
                                 -maxlength => 10)),
  $cgi->td($cgi->submit( -name  => 'change',
                         -value => 'Change Password'))),
  );
  print $cgi->end_form(), $cgi->hr();

  print $cgi->b("Existing users: ");
  my @users = $htpasswd->fetchUsers();
  print $cgi->p(@users);

  print $cgi->end_html();
  print "\n";
}
