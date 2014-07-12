% #+--------------------------------------+
% #|            User Setup tool           |
% #+--------------------------------------+
%
% # Enter a new user name or an old one to change
% # Select existing active username to be changed
% # Users cannot upgrade more than one's level.
% # - Level 3 can do level 2 plus create users and reset passwords
% # - Level 2 can make changes
% # - Level 1 cannot see any info

<%class>
    has 's' => (required => 1);
</%class>

<style>
#header { background-color: #DADADA; text-align:center; }
#tablebody { background-color: #DAFFDA; text-align:center; }
#centeredtext { text-align:center; }
#editlabel { text-align:right; background-color: white; }
#editdata { text-align:left; background-color: white; }
#tableedit { left:25%; float:center; width:50%; text-align:center; background-color: white; }
#access { text-align:center; background-color: white; }
#active { background-color: #DDFFDD; }
#cancelled { background-color: #FFEEAA; }
#frozen { background-color: #DDEEFF; }
#deleted { background-color: #EEEEEE; }
#default { background-color: #AAAAAA; }
#message { background-color: #AAAAAA; text-align:center; text-color:red; }
</style>

% if ( $message ) {
    <div id='message'><% $message | H %></div></br>
% }

% #+------------------------------------------------+
% #|                Create a new user               |
% #+------------------------------------------------+
% if ( $can_3 ) {
%   if ( defined $user and scalar(@$user) == 1 ) {
      <div align='center'>
          <a href='/home?s=users'>back</a>
      </div>
      </br>
%     } else {
      <div align='center'>
        Create User:&nbsp;
        <input name='new_user' type='text' size='10' value='<% ( $args->{new_user} || '' ) | H %>'>
        <input name='create_user' type='submit' value='Create'>
      </div>
%   }
% }

% #+------------------------------------------------+
% #|                    List users                  |
% #+------------------------------------------------+
% # List all users
% if ( defined $user and scalar @$user > 1 ) {
    <div><table width='100%'>
%   # Table header
% if ( $can_2 ) {
    <tr id='header'><td>Select</td><td>Username</td><td>Name</td><td>Status</td><td>Autorization</td><td>Created</td><td>Last updated</td></tr>
% } else {
    <tr id='header'><td>username</td><td>Name</td><td>Creation Date</td><td>Last updated Date</td></tr>
% }
%   foreach my $row ( @$user ) {
%     my $ha = Icemaker::Database::DBS->new()->get_hasharray({ 
%       db => 'development', 
%       sql => qq{ SELECT label, level FROM user_access WHERE user_id = ? and authorized = 'Y' }, 
%       bind_values => [$row->{id}], 
%    });
%    my $authorization = '';
%    foreach my $r ( @$ha  ){
%      $authorization .= "$r->{label}($r->{level}); ";
%    }
     <tr id='tablebody'>
%      my $style;
%      if ( $row->{status} eq 'Y' ) { $style = "active";
%      } elsif ( $row->{status} eq 'F' ) { $style = "frozen";
%      } elsif ( $row->{status} eq 'D' ) { $style = "deleted";
%      } elsif ( $row->{status} eq 'C' ) { $style = "cancelled";
%      } else { $style = "default";
%      } 
% if ( $can_2 ) {
       <td id='<% $style %>'><input name='selected_id' value="<% $row->{id} %>" type='submit'></td>
% }
       <td id='<% $style %>'><% $row->{username} %></td>
       <td id='<% $style %>'><% $row->{name} %></td>
% if ( $can_2 ) {
       <td id='<% $style %>'><% $row->{status} %></td>
       <td id='<% $style %>'><% $authorization %></td>
% }
       <td id='<% $style %>'><% $row->{creation_date} %></td>
       <td id='<% $style %>'><% $row->{last_updated_date} %></td>
     </tr>
%    }
   </table></div>

% #+------------------------------------------------+
% #|                   Edit User                    |
% #+------------------------------------------------+
% # One was selected and will be shown to edit from level 1 users
% } elsif ( defined $user and scalar @$user == 1 ) {
% # Not allowing users to edit their own preferences.
% $m->redirect('/home?s=users') if $user->[0]->{id} eq $m->session()->{user_data}->{id};

  <div align='center'><table id='tableedit'>
%   my $row = $user->[0];
    <tr id='editlabel'><td><b>Username:&nbsp;</b></td><td id='editdata'><% $row->{username} %></td></tr>
    <input name='username' value='<% $row->{username} %>' type='hidden'>
    <input name='selected_id' value='<% $row->{id} %>' type='hidden'>
    <tr id='editlabel'><td><b>Name:&nbsp;</b></td><td id='editdata'><input name='name' value="<% $row->{name} %>" type='text'></td></tr>
    <tr id='editlabel'><td><b>Status:&nbsp;</b></td>
% if ( $can_2 ) {
    <td id='editdata'>
      <select name='status'>
%     my $desc = { Y => "Active", F => "Frozen", C => "Cancelled", D => "Deleted" };
%     foreach my $status ( qw/Y F C D/ ) {
        <option value="<% $status %>" <% $status eq uc($row->{status}) ? "selected" : '' %>>
          <% $status %> - <% $desc->{$status} %>
        </option>
%     }
      </select>
% } else {
    <td>
      <% $row->{status} %>
% }   
    </td>
    </tr>
    <tr id='editlabel'><td><b>Created:&nbsp;</b></td><td id='editdata'><% $row->{creation_date} %></td></tr>
    <tr id='editlabel'><td><b>Last Updated:&nbsp;</b></td><td id='editdata'><% $row->{last_updated_date} %></td></tr>
  </table></div>

  <div></br></div>

% # Access data
  <div><table width='40%' align='center'>
    <tr id='header'><td>Access to:</td><td>Level</td><td>Authorized</td></tr>
%   my $show_save = 0;
%   foreach my $label ( @$all_labels ) {
% # if this user has less access than the user to change on this level, do not show it
%     if ( $m->session()->{user_access}->can($label, $user_access->{$label}->{level}) ) {
        <tr id='access'>
          <td><% $label %></td>
          <td>
            <select name="<% $label . '_level' %>">
%           foreach my $level ( qw/1 2 3/ ) {
%             if ( $m->session()->{user_access}->can($label,$level) ) {
%               $show_save = 1;
                <option value="<% $level %>" <% $level eq uc($user_access->{$label}->{level}) ? "selected" : '' %>><% $level || '-' %></option>
%             }
%           }
            </select>
          </td>
          <td><input name="<% $label %>" type="checkbox" value="Y" <% uc($user_access->{$label}->{authorized}) eq 'Y' ? 'checked' : '' %>></td>
        </tr>
%     } else {
%       foreach my $level ( qw/1 2 3/ ) {
%         if ( $level eq uc($user_access->{$label}->{level}) ) { 
            <input name="<% $label . '_level' %>" value="<% $level %>" type='hidden'>
            <input name="<% $label %>" value="<% uc($user_access->{$label}->{authorized}) %>" type='hidden'>
%         }
%       }
%     }
%   }
    </table>
  </div>
  </br>
% if ( $show_save ) {
  <div align='center'><table><tr><td></td><td><input type=submit name="Save" value="Save"></td><td></td></tr></table></div>
% } 
% #+------------------------------------------------+
% #|                  RESET PASSWORD                |
% #+------------------------------------------------+
%   if ( $m->session()->{user_access}->can('users',3) ) {
      <div align='center'><table><tr><td></td><td><input type=submit name="reset_password" value="Reset Password"></td><td></td></tr></table></div>
%   }
% }

% #+------------------------------------------------+
% #|                    INIT START                  |
% #+------------------------------------------------+
<%init>
    # Only users with level 1 or more are able to access this tool
    my $access = $m->session()->{user_access};
    my $can_1  = $access->can('users',1);
    my $can_2  = $access->can('users',2);
    my $can_3  = $access->can('users',3);
    $m->redirect('/home') unless $can_2;

    my $message = '';

    my $args = $m->request_args();
    my $user_access;
    my $all_labels = Icemaker::Database::DBS->new()->get_array({
        db  => 'development',
        sql => qq{ SELECT DISTINCT label FROM user_access },
    });

    my $user = get_user_list();

    # for when we have a specific id, gather all access info level
    if ( defined $args and defined $args->{selected_id} and $args->{selected_id} =~ m/[0-9]/ ) {
        my $user_access_list = Icemaker::Database::DBS->new()->get_hasharray({
            db  => 'development',
            sql => qq{ 
                SELECT label, level, authorized 
                FROM user_access WHERE user_id = ? 
            },
            bind_values => [ $args->{selected_id} ],
        });

        foreach my $r ( @$user_access_list ) {
            $user_access->{$r->{label}} = $r;
        }

        $user = Icemaker::Database::DBS->new()->get_hasharray({
            db  => 'development',
            sql => qq{ 
                SELECT id, username, name, status, creation_date, last_updated_date
                FROM user WHERE id = ? 
            },
            bind_values => [ $args->{selected_id} ],
        });
    }
 
    if ( defined $args and defined $args->{Save} ) {
        my $id = $args->{selected_id};
        foreach my $label ( @$all_labels ) {
            my $key = $label . "_level";
            my $level = defined $args->{$key} ? $args->{$key} : 1;
            my $authorized = defined $args->{$label} ? $args->{$label} : 'N';
            my $exist = Icemaker::Database::DBS->new()->get_hash({
                db  => 'development',
                sql => qq{ 
                    SELECT ua.* FROM user_access ua JOIN user u ON u.id = ua.user_id
                    WHERE ua.label = ? AND u.id = ? },
                bind_values => [ $label, $id ],
            });

            if ( $exist and defined $exist->{user_id} ) {
                Icemaker::Database::DBS->new()->execute({
                    db  => 'development',
                    sql => qq{ 
                        UPDATE user_access ua JOIN user u ON u.id = ua.user_id
                        SET ua.level = ?, ua.authorized = ? 
                        WHERE ua.label = ? AND u.id = ? },
                    bind_values => [ $level, $authorized, $label, $id ],
                });
            } else {
                Icemaker::Database::DBS->new()->execute({
                    db  => 'development',
                    sql => qq{ INSERT INTO user_access SET user_id = ?, label = ?, level = ?, authorized = ? },
                    bind_values => [ $id, $label, $level, $authorized ],
                });
            }
        }

        Icemaker::Database::DBS->new()->execute({
            db  => 'development',
            sql => qq{ UPDATE user SET name = ?, status = ? WHERE id = ? },
            bind_values => [ $args->{name}, $args->{status}, $id ],
        });

        $m->redirect('/home?s=users');
    }

    if ( defined $args and defined $args->{new_user} and length($args->{new_user}) and defined $args->{create_user} ) {
        my $username = $args->{new_user};
        $username =~ s/ //gi;
        if ( $user = get_user_by_username($username) ) {
        } else {
            Icemaker::Internal::User->create_user({ name => $username, username => $username });
            $user = get_user_by_username($username);
        }
    }

    if ( defined $args and defined $args->{reset_password} and defined $args->{selected_id} ) {
        # Reset password for the given user in args
        Icemaker::Database::DBS->new()->execute({
            db  => 'development',
            sql => qq{ UPDATE user SET password = '' WHERE id = ? },
            bind_values => [ $args->{selected_id} ],
        });
        $message = "Password was reset for this user";
    }
</%init>


<%perl>
sub get_user_list {
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ 
            SELECT id, username, name, status, creation_date, last_updated_date
            FROM user WHERE status = 'Y' ORDER BY status DESC, name ASC
        },
    });
}

sub get_user_by_username {
    my $username = shift || return [];
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ 
            SELECT id, username, name, status, creation_date, last_updated_date
            FROM user WHERE username = ?
        },
        bind_values => [ $username ],
    });
}

sub get_user_by_id {
    my $id = shift || return [];
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ 
            SELECT id, username, name, status, creation_date, last_updated_date
            FROM user WHERE id = ?
        },
        bind_values => [ $id ],
    });
}
</%perl>
