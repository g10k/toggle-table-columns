$.fn.initialize_toggle_columns = (options) ->
    # Добавляем кнопку "Применить"
    table_id_selector = $(this).attr('id')
    toggle_columns_div = options.toggle_columns_div;
    button_text = if options.button_text then options.button_text else 'Скрыть/показать столбцы'
    button_selector = if options.button_selector then options.button_selector else "apply_button"
    $(toggle_columns_div).append(
        $("<a id='#{button_selector}' class='btn btn-mini btn-success'><i class='icon-play'></i>#{button_text}</a>")
    )
    apply_button = $("##{button_selector}");

    # Создаем строчку с чекбоксами под заголовками.
    new_row_with_checkboxes = $('<tr></tr>')
    $.each($("##{table_id_selector} tr:first th"), (i,v)->
        $(this).attr('data-column-number',i);
        check_box = $("<input type='checkbox' checked/>")
        td_with_checkbox = $("<td data-column-number='#{i}'></td>");
        td_with_checkbox.click((e)->
            if e.target == this
                check_box.trigger('click')
        ).css('cursor','pointer')

        $(this).click((e)->
            td_with_checkbox.trigger('click')
        )
        $(this).css('cursor','pointer');
        new_row_with_checkboxes.append(td_with_checkbox.append(check_box))
    );
    new_row_with_checkboxes.insertAfter($("##{table_id_selector} tr:first"))

    # Добавляем ul где будут показываться скрытые столбцы
    hidden_column_names_div = apply_button.next('#hidden_columns_names');
    if (!hidden_column_names_div.length)
        hidden_column_names_div = $("<span></span>").attr('id','hidden_columns_names');
        hidden_column_names_div.append($("<ul class='unstyled toggle-columns'></ul>").attr('id','hidden_columns_ul'));
        hidden_column_names_div.insertAfter(apply_button);

    apply_button.click(()->
        showHeaders = $("##{table_id_selector} td input").map(()->
            return {
                'column_number': $(this).parents('td').attr('data-column-number'),
                'show':this.checked
            }
        );

        # Обрабатываем чекбоксы в таблице
        $.each($("##{table_id_selector} td input"), ()->
            show = $(this).prop('checked');
            cssIndex = +($(this).parents('td').attr('data-column-number')) + 1;
            tags_selector = "##{table_id_selector} th:nth-child(" + cssIndex + "), ##{table_id_selector} td:nth-child(" + cssIndex + ")";
            tags = $(tags_selector);
            if (show)
                tags.show();
            else
                tags.hide();
        );

        # Обрабатываем чекбоксы "Скрытых стобцов"
        $.each($("#hidden_columns_names input"), ()->
            show = $(this).prop('checked');
            cssIndex = +($(this).attr('data-column-number')) + 1;
            tags_selector = "##{table_id_selector} th:nth-child(" + cssIndex + "), ##{table_id_selector} td:nth-child(" + cssIndex + ")";
            tags = $(tags_selector);
            if (show)
                tags.show();
                tags.children('input').prop('checked',show);
            else
                tags.hide();
        );

        # Отображаем заново "Скрытые столбцы"
        hidden_column_names_div = $(this).next('#hidden_columns_names');
        hidden_columns = $("##{table_id_selector} th:hidden");
        col_numbers = hidden_columns.map(()->
            return +$(this).attr('data-column-number')
        )
        col_numbers = col_numbers.toArray()
        $.cookie('hidden_columns',col_numbers);
        hidden_columns_ul = $("#hidden_columns_ul");
        hidden_columns_ul.children().remove();
        if hidden_columns.length
            hidden_columns_ul.append($('<strong>Скрытые столбцы:</strong>'))

        $.each(hidden_columns, ()->
            column_number = $(this).attr('data-column-number');
            column_name = $(this).text();
            hidden_columns_ul.append(
                "<li class='unstyled inline'> <label class='checkbox'><input type='checkbox' data-column-number='#{column_number}'> #{column_name}&nbsp; </label></li>");
        );
        return false;
    )
    hidden_columns_from_cookie = $.cookie('hidden_columns');
    if !hidden_columns_from_cookie
        return
    hidden_columns_numbers = hidden_columns_from_cookie.split(',');
    $.each(hidden_columns_numbers,(i,v)->
        $("td[data-column-number='#{v}']").click();
    )
    apply_button.click();
    return;