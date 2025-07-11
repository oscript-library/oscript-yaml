#Использовать asserts
#Использовать ".."
#Использовать "."

&ТестовыйНабор
Процедура ПриСозданииОбъекта() Экспорт
КонецПроцедуры

&Тест
Процедура ТестПарсингаМногострочныхЛитералов() Экспорт
    // Дано
    СодержимоеФайла = ТестовыеУтилиты.ПрочитатьТекстФайла(ТестовыеУтилиты.ПолучитьПутьКТестовымДанным("multiline.yaml"));
    ЧтениеYaml = ТестовыеУтилиты.СоздатьЭкземплярПарсера();
    
    // Когда
    Результат = ЧтениеYaml.ПрочитатьYaml(СодержимоеФайла);
    
    // Тогда
    Ожидаем.Что(Результат).Не_().ЭтоНеопределено();
    
    Описание = Результат.Получить("description");
    Ожидаем.Что(Описание).Не_().ЭтоНеопределено();
    
    // Проверяем literal style (|) - сохраняет переводы строк
    Literal = Описание.Получить("literal");
    Ожидаем.Что(Literal).Не_().ЭтоНеопределено();
    ОжидаемыйLiteral = "Этот текст" + Символы.ПС + "сохраняет переводы строк" + Символы.ПС + "как есть";
    Ожидаем.Что(Literal).Равно(ОжидаемыйLiteral);
    
    // Проверяем folded style (>) - сворачивает переводы строк в пробелы
    Folded = Описание.Получить("folded");
    Ожидаем.Что(Folded).Не_().ЭтоНеопределено();
    ОжидаемыйFolded = "Этот текст сворачивается в одну строку с пробелами между словами";
    Ожидаем.Что(Folded).Равно(ОжидаемыйFolded);
    
    // Проверяем простой literal
    ПростойLiteral = Результат.Получить("simple_literal");
    Ожидаем.Что(ПростойLiteral).Не_().ЭтоНеопределено();
    ОжидаемыйПростойLiteral = "Простой пример" + Символы.ПС + "многострочного текста";
    Ожидаем.Что(ПростойLiteral).Равно(ОжидаемыйПростойLiteral);
    
    // Проверяем простой folded
    ПростойFolded = Результат.Получить("simple_folded");
    Ожидаем.Что(ПростойFolded).Не_().ЭтоНеопределено();
    ОжидаемыйПростойFolded = "Простой пример складываемого текста на несколько строк";
    Ожидаем.Что(ПростойFolded).Равно(ОжидаемыйПростойFolded);
    
    // Проверяем script
    Скрипт = Результат.Получить("script");
    Ожидаем.Что(Скрипт).Не_().ЭтоНеопределено();
    ОжидаемыйСкрипт = "#!/bin/bash" + Символы.ПС + "echo ""Hello World""" + Символы.ПС + "exit 0";
    Ожидаем.Что(Скрипт).Равно(ОжидаемыйСкрипт);
    
    // Проверяем SQL запрос
    SqlQuery = Результат.Получить("sql_query");
    Ожидаем.Что(SqlQuery).Не_().ЭтоНеопределено();
    ОжидаемыйSql = "SELECT *" + Символы.ПС + "FROM users" + Символы.ПС + "WHERE active = true" + Символы.ПС + "ORDER BY name;";
    Ожидаем.Что(SqlQuery).Равно(ОжидаемыйSql);
КонецПроцедуры

&Тест
Процедура ТестПарсингаЛитераловСИндикаторами() Экспорт
    // Дано
    ТекстYaml = "
    |data: |
    |  Первая строка
    |  Вторая строка
    |  Третья строка
    |
    |compact: >
    |  Эти строки
    |  будут объединены
    |  в одну строку
    |";
    ЧтениеYaml = ТестовыеУтилиты.СоздатьЭкземплярПарсера();
    
    // Когда
    Результат = ЧтениеYaml.ПрочитатьYaml(ТекстYaml);
    
    // Тогда
    Ожидаем.Что(Результат).Не_().ЭтоНеопределено();
    
    Данные = Результат.Получить("data");
    Ожидаем.Что(Данные).Не_().ЭтоНеопределено();
    ОжидаемыеДанные = "Первая строка" + Символы.ПС + "Вторая строка" + Символы.ПС + "Третья строка";
    Ожидаем.Что(Данные).Равно(ОжидаемыеДанные);
    
    Компактные = Результат.Получить("compact");
    Ожидаем.Что(Компактные).Не_().ЭтоНеопределено();
    ОжидаемыеКомпактные = "Эти строки будут объединены в одну строку";
    Ожидаем.Что(Компактные).Равно(ОжидаемыеКомпактные);
КонецПроцедуры
