module WelcomeHelper
  def grid()
    id = cookies.signed[:game_id]
    elements = REDIS.lrange("grid_#{id}", 0, -1 )
    row = Math.sqrt(REDIS.llen("grid_#{id}"))
    temp = row
    index = 0
    html = '<table id="grid">'
    while row > 0
      html += '<tr>'
      col = temp
      row-=1
    while col > 0
      col-=1  
      html += "<td>#{elements[index]}</td>"
      index+=1
      end
      html += '</tr>'
    end
    html += '</table>'
    return html.html_safe
  end
end

