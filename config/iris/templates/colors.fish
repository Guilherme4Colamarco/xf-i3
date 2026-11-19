# iris -> fish. O iris-wall roda este arquivo com `fish -c source`; como são
# variáveis universais (set -U), todo fish aberto muda de cor na hora.
# Edite ~/.config/iris/templates/colors.fish.
set -U fish_color_normal {fg.strip}
set -U fish_color_command {accent.strip}
set -U fish_color_keyword {syntax_keyword.strip}
set -U fish_color_quote {syntax_string.strip}
set -U fish_color_redirection {syntax_operator.strip}
set -U fish_color_end {syntax_keyword.strip}
set -U fish_color_error {red.strip}
set -U fish_color_param {fg.strip}
set -U fish_color_option {syntax_param.strip}
set -U fish_color_comment {syntax_comment.strip}
set -U fish_color_operator {syntax_operator.strip}
set -U fish_color_escape {syntax_const.strip}
set -U fish_color_autosuggestion {dim.strip}
set -U fish_color_cancel {red.strip}
set -U fish_color_selection --background={surface.strip}
set -U fish_color_search_match --background={surface.strip}
set -U fish_color_valid_path --underline
set -U fish_pager_color_progress {dim.strip}
set -U fish_pager_color_prefix {accent.strip} --bold
set -U fish_pager_color_completion {fg.strip}
set -U fish_pager_color_description {dim.strip}
set -U fish_pager_color_selected_background --background={surface.strip}
