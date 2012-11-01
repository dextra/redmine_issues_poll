$("#issues_poll_area").html("<%= escape_javascript(render :partial => 'hooks/view_polls_form') %>");

<% if @success %>
	<% if @added %>
	  alert("<%= t(:bet_successful_created) %>");
	<% else %>
	  alert("<%= t(:bet_successful_canceled) %>");
	<% end %>
<% else %>
  	alert("<%= @bet.errors.full_messages.join('\n') %>");
<% end %>