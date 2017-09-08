class Array
  # 可以使用 current_member.member_service.create(a: 123)
  def create attributes
    map(&:class).uniq.first.create! attributes
  end

  def find_by_id id
    klass = map(&:class).uniq.first
    klass.find last.member, id
  end
  alias_method :find_by_member_and_id, :find_by_id
end
