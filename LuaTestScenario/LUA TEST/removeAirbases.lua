local width, height, numberOfMaps = civ.getMapDimensions()
for x=0,width do
    for y=0,height do
        for z=0,numberOfMaps do
            if civ.getTile(x,y,z) then
                tile = civ.getTile(x,y,z)
                -- Check if the bit with value 2 and bit with value 64 are both 1
                if tile.improvements & 66 == 66 then
                    -- set the bit with value 2 and the bit with value 64 to 0
                    -- All bits together have value of -1 (remember most significant
                    -- bit has value -128) so subtract 66 from -1 to set the 2 bits to 0
                    -- Apply bitwise and, ie &
                    tile.improvements = tile.improvements & -67
                end
             end
         end
     end
end
