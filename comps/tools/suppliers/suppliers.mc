% #+------------------------------------------+
% #|            Supplier Setup tool           |
% #+------------------------------------------+
%
% # Enter a new supplier name or an old on to change
% # Select exiting active suppliers to be changed
% # List all suppliers at start
% # - Level 3 can create, update, reactivate
% # - Level 2 can create, update, reactivate
% # - Level 1 can read only

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
#inactive { background-color: #FFEEAA; }
</style>

% if ( $message ) {
    <div id='message'><% $message | H %></div></br>
% }

% #+------------------------------------------------+
% #|              Create a new supplier             |
% #+------------------------------------------------+
% if ( $can_2 ) {
%   if ( defined $supplier and scalar(@$supplier) == 1 ) {
      <div align='center'>
          <a href='/home?s=suppliers'>back</a>
      </div>
      </br>
%     } else {
      <div align='center'>
        Create Supplier:&nbsp;
        <input name='new_supplier' type='text' size='10' value='<% ( $args->{new_supplier} || '' ) | H %>'>
        <input name='create_supplier' type='submit' value='Create'>
      </div>
%   }
% }

% #+------------------------------------------------+
% #|                 List suppliers                 |
% #+------------------------------------------------+
% # List all suppliers
% if ( defined $supplier and scalar @$supplier > 1 ) {
    <div><table width='100%'>
%   # Table header
% if ( $can_2 ) {
     <tr id='header'><td>Select</td><td>Supplier</td><td>Phone</td><td>Email</td><td>Status</td><td>Creation Date</td><td>Last updated Date</td></tr>
% } else {
     <tr id='header'><td>Supplier</td><td>Phone</td><td>Email</td><td>Status</td><td>Creation Date</td><td>Last updated Date</td></tr>
% }
%    foreach my $row ( @$supplier ) {
      <tr id='tablebody'>
%     my $style;
%     if ( $row->{status} eq 'Active' ) { $style = "active"; } else { $style = "inactive"; } 
% if ( $can_2 ) {
      <td id='<% $style %>'><input name='selected_id' value="<% $row->{id} %>" type='submit'></td>
% }
      <td id='<% $style %>'><% $row->{name} %></td>
      <td id='<% $style %>'><% $row->{phone} %></td>
      <td id='<% $style %>'><% $row->{email} %></td>
      <td id='<% $style %>'><% $row->{status} %></td>
      <td id='<% $style %>'><% $row->{creation_date} %></td>
      <td id='<% $style %>'><% $row->{last_updated_date} %></td>
     </tr>
%    }
   </table></div>

% #+------------------------------------------------+
% #|                 Edit Supplier                  |
% #+------------------------------------------------+
% # One was selected and will be shown to edit from level 1 users
% } elsif ( defined $supplier and scalar @$supplier == 1 ) {
%  $m->redirect('/home?s=suppliers') unless $can_2;
   <div align='center'><table id='tableedit'>
%  foreach my $row ( @$supplier ) {
     <tr id='editlabel'><td><b>Supplier:&nbsp;</b></td><td id='editdata'><% $row->{name} %></td></tr>
      <input name='name' value='<% $row->{name} %>' type='hidden'>
      <input name='id' value='<% $row->{id} %>' type='hidden'>
     <tr id='editlabel'><td><b>Phone:&nbsp;</b></td><td id='editdata'><input name='phone' value="<% $row->{phone} %>" type='text'></td></tr>
     <tr id='editlabel'><td><b>Email:&nbsp;</b></td><td id='editdata'><input name='email' value="<% $row->{email} %>" type='text'></td></tr>
     <tr id='editlabel'><td><b>Status:&nbsp;</b></td><td id='editdata'>
       <select name='status'>
%      foreach my $status ( qw/Active Inactive/ ) {
        <option value="<% $status %>" <% $status eq $row->{status} ? "selected" : '' %>><% $status %></option>
%      }
       </select>
      </td>
     </tr>
     <tr id='editlabel'><td><b>Created:&nbsp;</b></td><td id='editdata'><% $row->{creation_date} %></td></tr>
     <tr id='editlabel'><td><b>Last Updated:&nbsp;</b></td><td id='editdata'><% $row->{last_updated_date} %></td></tr>
%  }
   </table></div>

   <div></br></div>

   <div align='center'><table><tr><td></td><td><input type=submit name="Save" value="Save"></td><td></td></tr></table></div>
% }

% #+------------------------------------------------+
% #|                    INIT START                  |
% #+------------------------------------------------+
<%init>
    # Only users with level 1 or more are able to access this tool
    my $access = $m->session()->{user_access};
    my $can_1  = $access->can('suppliers',1);
    my $can_2  = $access->can('suppliers',2);
    my $can_3  = $access->can('suppliers',3);
    $m->redirect('/home') unless $can_1;

    my $message = '';

    my $args = $m->request_args();
    my $supplier = get_suppliers();

    # for when we have a selected id, gather all access info level
    if ( defined $args and defined $args->{selected_id} and $args->{selected_id} =~ m/[0-9]/ ) {
        $supplier = get_supplier_by_id($args->{selected_id});
    }
 
    if ( defined $args and defined $args->{Save} ) {
        Icemaker::Database::DBS->new()->execute({
            db  => 'development',
            sql => qq{ UPDATE supplier SET status = ?, name = ?, phone = ?, email = ? WHERE id = ? },
            bind_values => [ $args->{status}, $args->{name}, $args->{phone}, $args->{email}, $args->{id} ],
        });
        $supplier = get_suppliers();
    }

    if ( defined $args and defined $args->{new_supplier} and length($args->{new_supplier}) and defined $args->{create_supplier} ) {
        if ( $supplier = get_supplier_by_name($args->{new_supplier}) ) {
        } else {
            Icemaker::Internal::Supplier->create_supplier({ name => $args->{new_supplier} });
            $supplier = get_supplier_by_name($args->{new_supplier});
        }
    }

</%init>

<%perl>
sub get_suppliers {
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{ SELECT * FROM supplier WHERE status = 'Active' ORDER BY name ASC },
    });
}
sub get_supplier_by_id {
    my $id = shift || return [];
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{
            SELECT *
            FROM supplier WHERE id = ?
        },
        bind_values => [ $id ],
    });
}
sub get_supplier_by_name {
    my $name = shift || return [];
    return Icemaker::Database::DBS->new()->get_hasharray({
        db  => 'development',
        sql => qq{
            SELECT *
            FROM supplier WHERE name = ?
        },
        bind_values => [ $name ],
    });
}
</%perl>

