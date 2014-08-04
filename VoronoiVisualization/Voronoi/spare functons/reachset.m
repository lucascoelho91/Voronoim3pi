function bot = reachset(bot)

% Number of agents
n = length([bot.id]);

for i = 1:n
   % Generate possible steps
   a = sqrt(2);
   xmoves = [-1 0 1 0 0 -a a -a a] + bot(i).x;
   ymoves = [0 -1 0 1 0 -a -a a a] + bot(i).y;
   % Check to make sure its inside Voronoi cell
   V = bot(i).Vi;
   reach = [];
   % Verify the points are in the cell boundary
   for j = 1:length(xmoves)
       if inpolygon(xmoves(j),ymoves(j),V(:,1),V(:,2))
           reach = horzcat(reach, [xmoves(j) ; ymoves(j)]);
       end
   end
   
   bot(i).reach = reach;
      
    
end