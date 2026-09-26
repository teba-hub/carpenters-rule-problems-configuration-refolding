function points = reconstruct_linkage_vertices(angles, anchor, lengths)
    %RECONSTRUCT_LINKAGE_VERTICES Recover vertices from angles and lengths.

    n = length(lengths) + 1;
    points = zeros(n, 2);
    points(1, :) = anchor;

    for index = 2:n
        points(index, :) = points(index-1, :) + ...
            lengths(index-1) * ...
            [cos(angles(index-1)), sin(angles(index-1))];
    end
end
