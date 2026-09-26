function style = resolve_plot_style(style)
    %RESOLVE_PLOT_STYLE Apply defaults to polygon appearance settings.

    if nargin < 1 || isempty(style)
        style = struct();
    end
    if ~isfield(style, 'line_width')
        style.line_width = 1.2;
    end
    if ~isfield(style, 'marker_size')
        style.marker_size = 4;
    end

    validateattributes(style.line_width, {'numeric'}, ...
                       {'scalar', 'real', 'finite', 'positive'});
    validateattributes(style.marker_size, {'numeric'}, ...
                       {'scalar', 'real', 'finite', 'positive'});
end
