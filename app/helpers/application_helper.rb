module ApplicationHelper
  def dash_nav_class(path_pattern)
    current_path = request.path
    base_class = "flex items-center gap-3 w-full px-3 py-2.5 text-sm font-medium rounded-lg transition-colors"

    is_active = current_path.start_with?(path_pattern)

    if is_active
      "#{base_class} bg-gray-900 text-white"
    else
      "#{base_class} text-gray-600 hover:text-gray-900 hover:bg-gray-100"
    end
  end

  def user_avatar(user, size: :md, css: "")
    sizes = { sm: "w-10 h-10 text-sm", md: "w-12 h-12 text-base", lg: "w-16 h-16 text-xl", xl: "w-24 h-24 text-3xl" }
    img_sizes = { sm: 40, md: 48, lg: 64, xl: 96 }
    size_class = sizes[size]
    px = img_sizes[size]

    if user&.avatar&.attached?
      image_tag user.avatar.variant(resize_to_fill: [ px * 2, px * 2 ]),
        class: "#{size_class} rounded-xl object-cover #{css}",
        alt: user&.name
    else
      content_tag :div, user&.name&.first&.upcase || "?",
        class: "avatar avatar-primary #{size_class} #{css}"
    end
  end
end
