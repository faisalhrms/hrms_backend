module ParamsCountPatch
  def count(*args, &block)
    (permitted? ? to_h : to_unsafe_h).count(*args, &block)
  rescue ActionController::UnfilteredParameters
    to_unsafe_h.count(*args, &block)
  end
end

ActionController::Parameters.prepend(ParamsCountPatch)
