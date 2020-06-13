using Plots
using GR


gr()

data = [5, 5, 5, 5]
data2 = [7, 6, 5, 5]
egzemplarze = [2,2,3,4]

p = Plots.plot(egzemplarze, data, seriestype = :bar, bar_position = :stack)
Plots.plot!(p, egzemplarze, data2, seriestype = :bar, bar_position = :stack)

