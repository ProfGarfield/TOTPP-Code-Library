-- This is a file of utilities for scenario makers for the Test of Time Patch Project lua events.
-- Author: Prof. Garfield of Civfanatics Forums
-- You may freely redistribute and modify these functions, and even include them in other library files.
-- I would consider it polite if the documentation noted that I was the original author and made note if
-- the work was modified.

-- the USER INFORMATION section of a function description should be enough information for a scenario 
-- maker to use the function I've created.  The DEVELOPER INFORMATION section gives some extra information
-- for someone who needs to debug the code if I'm no longer around.

-- inPolygon(tile,vertexTable,map) -> boolean
--  USER INFORMATION
--      DO NOT DRAW A POLYGON THAT CROSSES THE DATE LINE
--      DO NOT HAVE THE SAME COORDINATE TWICE
--      tile is a tile object
--      vertexTable is a table of tables, where the interior tables give the x and y 
--          coordinates of the polygon vertices and vertexTable is an ORDERED table of these
--          coordinates.  That is, if you were drawing the polygon, you would start at the
--          coordinate vertexTable[1], then move your pen to vertexTable[2], then to vertexTable[3]
--          and so on until you reached vertexTable[n], after which you would move your pen to
--          vertexTable[1] to close your polygon.
--          vtA={{1,1},{2,4},{5,3},{3,3},{3,1}} is different from 
--          vtB={{1,1},{2,4},{5,3},{3,1},{3,3}}
--          Note that including a z coordinate in the vertex specification is OK, but will be ignored
--      map is an integer in 0,1,2,3 that specifies the map that the polygon is found on
--         
--
--  DEVELOPER INFORMATION 
--      How this function works:
--      A polygon is defined by the line segments that are drawn between ordered pairs of vertices.
--      If I cross a line segment, it means I am moving from inside the polygon to outside, or from
--      outside the polygon into it.  If I have 2 points, A and B, a continuous path P between A and B,
--      and I know that B is outside the polygon, then by counting the number of times P crosses a
--      polygon line segment, I can determine whether A is inside or outside the polygon in question.
--      This function will use the tile we are checking as point and then follow a line in both directions
--      until the line goes off the map board.  If on each "side" of the point there are an odd number
--      of line segment crossings, then we know the point is inside the polygon.
--
--      Any line passing through the tile will work, so we can use a line with the same slope each time.
--      The slopes of all line segments will be rational for rational coordinate choices, so if we choose
--      an irrational slope, then, barring rounding error, we should never have a line segment parallel
--      to our path line, and don't have to check for that case.

function inPolygon(tile, vertexTable,map)
    if tile.z ~= map then -- If the map doesn't match, we don't have to do anything else
        return false
    end
    local slope = (1+math.sqrt(5))/2    -- Slope of the line we are using as a path 
                                        -- Use the golden ratio since it is the "most irrational" number
    local px = tile.x
    local py = tile.y
    local vertices = #vertexTable
    local positiveCrossings = 0 -- Line segment crossings when leaving tile point in "positive" direction 
    local negativeCrossings = 0 -- Line segment crossings when leaving tile point in "negative" direction
    for i=1,vertices do
        local ux = vertexTable[i][1]
        local uy = vertexTable[i][2]
        if i >=2 then
            vx = vertexTable[i-1][1]
            vy = vertexTable[i-1][2]
        else -- If i==1, we want our other vertex to come from the last element of the vertex table
            vx = vertexTable[vertices][1]
            vy = vertexTable[vertices][2]
        end
        segSlope = (uy-vy)/(ux-vx) -- Slope of the line segment we are checking
        -- First we check where our path crosses the line defined by u and v
        -- system is (matrix notation)
        --  |-           -||--|   |-            -|
        --  |-slope     1 ||x | = |py - slope*px |
        --  |-segSlope  1 ||y |   |uy-segSlope*ux|
        --  |-           -||--|   |-            -|
        -- Use Cramer's rule to solve
        local A = py - slope*px
        local B = uy - segSlope*ux
        local xStar = (A-B)/(-slope+segSlope)
        local yStar = (-slope*B+segSlope*A)/(-slope+segSlope)
        -- Next we check if xStar and yStar are on the line segment by solving
        --  |-     -||--|   |-   -|
        --  |ux  vx ||f | = |xStar|
        --  |uy  vy ||g |   |ystar|
        --  |-     -||--|   |-   -|
        --  If 0<=f<=1 and 0<=g<=1 and f+g == 1, then xStar, yStar is on the segment
        local f = (xStar*vy-yStar*vx)/(ux*vy-uy*vx)
        local g = (ux*yStar-uy*xStar)/(ux*vy-uy*vx)
        local er = math.abs(f+g-1) -- er == 0 when f+g == 1.  by checking er <= 1e-6, we have a small tollerance
                                   -- to account for rounding error
        local zeroTolerance = 1e-6
        if f>=0 and f <=1 and g>=0 and g<=1 and er <= zeroTolerance then
            -- Now we determine if the crossing is in the positive direction from the tile or the negative
            local t = (yStar - py)/slope
            if t == 0 then
                --This means the tile point is exactly on the line segment and therefore automatically in the polygon
                return true
            elseif t > 0 then
                positiveCrossings = positiveCrossings +1
            elseif t < 0 then
                negativeCrossings = negativeCrossings +1
            end
        end
    end
    if positiveCrossings % 2 ==1 and negativeCrossings % 2 == 1 then
        return true
    else
        return false
    end
end
            
return {inPolygon=inPolygon,}
