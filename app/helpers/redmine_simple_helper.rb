module RedmineSimpleHelper
  def link_to_new_issue_simplify_on(project)
    link_to_new_issue_simplify_link(project, 'on')
  end

  def link_to_new_issue_simplify_off(project)
    link_to_new_issue_simplify_link(project, 'off')
  end

  def link_to_new_issue_simplify_link(project, simplify)
    raise ArgumentError('allowed only on|off values') unless simplify =~ /^on|off$/
    link_class = "simplify-#{simplify}"
    link_to l("text_simplify_#{simplify}"),
            switch_simple_mode_for_new_path(project.to_param),
            { :class => link_class }
  end

  def link_to_edit_issue_simplify_on(issue)
    link_to_edit_issue_simplify_link(issue, 'on')
  end

  def link_to_edit_issue_simplify_off(issue)
    link_to_edit_issue_simplify_link(issue, 'off')
  end

  def link_to_edit_issue_simplify_link(issue, simplify)
    raise ArgumentError('allowed only on|off values') unless simplify =~ /^on|off$/
    link_class = "simplify-#{simplify}"
    link_to l("text_simplify_#{simplify}"),
            edit_issue_path(issue),
            { :class => link_class }
  end

  def assignee_for_select(issue)
    # assignable_users + non_members
    data = { :more => false, :results => [] }
    members, groups = issue.assignable_users.sort.partition { |u| u.is_a? User }
    non_members = User.current.allowed_to?(:manage_members, issue.project) ?
        User.active.not_member_of(issue.project).sort : []

    # me
    data[:results] << user_to_select2_item(
        User.current,
        :text => "<< #{l(:label_me)} >>",
        :name => User.current.name
    )

    # author
    if User.current.id != issue.author.id
      data[:results] << user_to_select2_item(
          issue.author,
          :text => "<< #{l(:field_author)} >>",
          :name => issue.author.name
      )
    end

    # members
    data[:results] += members.map { |u| user_to_select2_item(u) }

    # groups
    if groups.any?
      data[:results] << {
          :text => l(:label_group),
          :children => groups.map { |u| user_to_select2_item(u) }
      }
    end

    # non members
    if non_members.any?
      data[:results] << {
          :text => l(:label_role_non_member),
          :children => non_members.map do |u|
            user_to_select2_item(u, :non_member => true)
          end
      }
    end
    data
  end

  def watchers_for_select(issue)
    # me, members + non_members
    data = { :more => false, :results => [] }

    member_ids = issue.project.users.pluck(:user_id).map(&:to_i)
    members, non_members =
        User.active.sort.partition { |u| member_ids.include?(u.id) }

    # me
    data[:results] << user_to_select2_item(
        User.current,
        :text => "<< #{l(:label_me)} >>",
        :name => User.current.name
    )

    # members
    data[:results] += members.map { |u| user_to_select2_item(u) }

    # non members
    if non_members.any?
      data[:results] << {
          :text => l(:label_role_non_member),
          :children => non_members.map do |u|
            user_to_select2_item(u, :non_member => true)
          end
      }
    end
    data
  end

  def user_to_select2_item(*args)
    options = args.extract_options!
    user = args[0]
    {
        :id => user.id,
        :text => user.name,
        :login => user.login,
        :email => user.mail
    }.merge(options)
  end
end
