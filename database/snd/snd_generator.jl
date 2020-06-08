using LightXML

relation = Dict()
sizes = [30, 35, 40, 45, 50]

open("database/snd/networks.txt", "w") do io
    for size = sizes
        write(io, "$(length(sizes) * 5)\n")
        for n = 1:5
            xdoc = parse_file("/home/pan/Studia/inzynierka/database/snd/directed-germany50-DFN-aggregated-1month-over-1year/demandMatrix-germany50-DFN-1month-20040$(n).xml")

            xroot = root(xdoc)

            nS = find_element(xroot, "networkStructure")
            nodes = find_element(nS, "nodes")
            i = 1
            for node in get_elements_by_tagname(nodes, "node")
                city = attribute(node, "id")
                crds = find_element(node, "coordinates")
                value_x = content(find_element(crds, "x"))
                value_y = content(find_element(crds, "y"))
                relation[city] = (i, parse(Float64,value_x), parse(Float64, value_y))
                i += 1
            end


            r = zeros(Int, length(relation), length(relation))
            demands = find_element(xroot, "demands")
            for demand in get_elements_by_tagname(demands, "demand")
                source = content(find_element(demand, "source"))
                target = content(find_element(demand, "target"))
                demand_value = content(find_element(demand, "demandValue"))
                value_float = parse(Float64, demand_value)
                requirement = 0
                if value_float < 1.
                    requirement = 1
                elseif value_float < 5.
                    requirement = 2
                elseif value_float < 10.
                    requirement = 3
                elseif value_float < 50.
                    requirement = 4
                else
                                    requirement = 5
                end
                
                if size >= 40 && value_float >= 100
                    requirement = 6
                end

                r[first(relation[source]), first(relation[target])] = requirement
            end

            g = Graph(length(relation))
            while length(relation) != 0
                data = last(pop!(relation))
                
                for (i,data2) in relation
                    add_edge!(g, first(data), first(data2), sqrt((data[2] - data2[2])^2 + (data[3] - data2[3])^2) )
                end
            end

            for i = size + 1:50
                rem_vertex!(g, i)
            end
            write(io, "$(size)\n")
            for v = 1:size
                for vi = v + 1:size
                    write(io, "$(weight(g, v, vi)) ")
                end
                write(io, "\n")
            end
            for col = 1:size
                for row = 1:size
                    write(io, "$(r[col, row]) ")
                end
                write(io, "\n")
            end            
            LightXML.free(xdoc)
        end
    end
end