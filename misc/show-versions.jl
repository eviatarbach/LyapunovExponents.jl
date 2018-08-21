for line in split(strip(read("REQUIRE", String)), '\n')[2:end]
    name = split(line)[1]
    println(name, "\t", Pkg.installed(name))
end
