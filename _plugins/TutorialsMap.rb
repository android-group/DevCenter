# require 'pry'
# require 'pry-byebug'

def TutorialsMap_GetChildren(url, site)
  # Caching mechanism
  if !site['children']
    site['children'] = {}
  elsif site['children'] && site['children']["#{url}"]
    return site['children'][url]
  end

  # Array to be returned
  children = []

  # Break down URL
  parts = url.split('/')
  target_level = parts.count + 1

  # Loop over all the pages, performance improvements welcomed
  site['pages'].each do |page|
    level = page.url.split('/').count
    # Look for URLs of the same level (number of /) and sharing the same parent.
    next unless (level == target_level) && (page.url.include? url)
    element = {}
    element['url'] = page.url
    element['title'] = page.data['title']

    if page.data['breadcrumb_title']
      element['breadcrumb_title'] = page.data['breadcrumb_title']
    else
      element['breadcrumb_title'] = page.data['title']
    end

    if page.data['weight']
      element['weight'] = page.data['weight']
    else
      element['weight'] = 1000
    end

    element['show_in_nav'] = page.data['show_in_nav']

    element['children'] = TutorialsMap_GetChildren(page.url, site)

    children.push(element)
  end

  children = children.sort { |x, y| x['weight'] <=> y['weight'] }

  # Caching
  site['children']["#{url}"] = children

  children
end

Jekyll::Hooks.register :site, :pre_render do |site, payload|
  payload["site"]["data"]["tutorials"] = TutorialsMap_GetChildren("/tutorials/", payload["site"])
  # binding.pry

end
