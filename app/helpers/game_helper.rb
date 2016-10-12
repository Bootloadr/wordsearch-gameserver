module GameHelper
   def game()
     gameid = cookies.signed[:game_id]
     REDIS.sunionstore("players", gameid)
     html = '<table id="game">'
       html += '<thead>'
       html +="<th>Players</th>"
       html +="<th>Scores</th>"
       html += '</thead>'
       html +='<tbody>'
     while REDIS.scard("players") != 0
       pl = REDIS.spop("players")
      
       html += '<tr>'   
       html += "<td>#{REDIS.hget(pl,"name")}</td>"
      # html+= '</tr>'
      # html += '<tr>'   
       html += "<td>#{REDIS.hget(pl,"points" )}</td>"
       html += '</tr>'
     end
       html +='</tbody>'
       html+='</table>'
       return html.html_safe
   end
 end