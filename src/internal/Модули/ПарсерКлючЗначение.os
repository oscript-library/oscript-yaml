// Модуль для парсинга ключ-значение структур YAML
//

// Разбор строки на ключ и значение
//
// Параметры:
//   ОчищеннаяСтрока - Строка - строка для разбора
//
// Возвращаемое значение:
//   Структура - структура с ключом и значением или Неопределено
//
Функция РазобратьКлючЗначение(ОчищеннаяСтрока) Экспорт
	ПозицияДвоеточия = НайтиПозициюДвоеточия(ОчищеннаяСтрока);
	Если ПозицияДвоеточия = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	КлючСКавычками = СокрЛП(Лев(ОчищеннаяСтрока, ПозицияДвоеточия - 1));
	ЗначениеСтрока = СокрЛП(Сред(ОчищеннаяСтрока, ПозицияДвоеточия + 1));
	
	// Обрабатываем ключ, убирая кавычки если они есть
	Ключ = ПреобразовательЗначений.ОбработатьКлючВКавычках(КлючСКавычками);
	
	// Удаляем комментарии из значения
	ЗначениеСтрока = ПарсерУровней.УдалитьКомментарии(ЗначениеСтрока);
	
	Возврат Новый Структура("Ключ, Значение", Ключ, ЗначениеСтрока);
КонецФункции

// Проверка, является ли строка YAML merge
//
// Параметры:
//   ОчищеннаяСтрока - Строка - очищенная строка
//
// Возвращаемое значение:
//   Булево - Истина, если это YAML merge
//
Функция ЭтоYAMLMerge(ОчищеннаяСтрока) Экспорт
	Возврат Лев(ОчищеннаяСтрока, 3) = "<<:";
КонецФункции

// Обработка YAML merge
//
// Параметры:
//   ОчищеннаяСтрока - Строка - строка с merge
//   ТекущийКонтекст - Соответствие - текущий контекст
//   МенеджерЯкорей - Объект - менеджер якорей
//
Процедура ОбработатьYAMLMerge(ОчищеннаяСтрока, ТекущийКонтекст, МенеджерЯкорей) Экспорт
	ЗначениеСтрока = СокрЛП(Сред(ОчищеннаяСтрока, 4));
	
	Если Лев(ЗначениеСтрока, 1) = "*" Тогда
		ИмяЯкоря = Сред(ЗначениеСтрока, 2);
		ЗначениеЯкоря = МенеджерЯкорей.ПолучитьЗначениеЯкоря(ИмяЯкоря);
		
		Если ЗначениеЯкоря <> Неопределено 
			И ТипЗнч(ЗначениеЯкоря) = Тип("Соответствие") 
			И ТипЗнч(ТекущийКонтекст) = Тип("Соответствие") Тогда
			СлитьСоответствия(ЗначениеЯкоря, ТекущийКонтекст);
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

// Слияние двух соответствий (копирование всех ключей из источника в приемник)
//
// Параметры:
//   Источник - Соответствие - источник данных
//   Приемник - Соответствие - приемник данных
//
Процедура СлитьСоответствия(Источник, Приемник) Экспорт
	Для Каждого КлючЗначение Из Источник Цикл
		Приемник.Вставить(КлючЗначение.Ключ, КлючЗначение.Значение);
	КонецЦикла;
КонецПроцедуры

// Находит позицию двоеточия, игнорируя двоеточия внутри кавычек или строковых значений
//
// Параметры:
//   Строка - Строка - строка для поиска
//
// Возвращаемое значение:
//   Число - позиция двоеточия или 0, если не найдено
//
Функция НайтиПозициюДвоеточия(Строка)
	ВКавычках = Ложь;
	ТипКавычек = "";
	
	Для Позиция = 1 По СтрДлина(Строка) Цикл
		Символ = Сред(Строка, Позиция, 1);
		
		// Обработка состояния "в кавычках"
		Если ОбработатьКавычки(Символ, ВКавычках, ТипКавычек) Тогда
			Продолжить;
		КонецЕсли;
		
		// Если мы внутри кавычек, пропускаем проверку двоеточия
		Если ВКавычках Тогда
			Продолжить;
		КонецЕсли;
		
		// Проверка на двоеточие
		Если Символ = ":" И ЭтоРазделительДвоеточие(Строка, Позиция) Тогда
			Возврат Позиция;
		КонецЕсли;
	КонецЦикла;
	
	Возврат 0;
КонецФункции

// Обрабатывает кавычки и обновляет состояние "в кавычках"
//
// Параметры:
//   Символ - Строка - текущий символ
//   ВКавычках - Булево - состояние "в кавычках" (передается по ссылке)
//   ТипКавычек - Строка - тип кавычек (передается по ссылке)
//
// Возвращаемое значение:
//   Булево - Истина, если символ был кавычкой и обработан
//
Функция ОбработатьКавычки(Символ, ВКавычках, ТипКавычек)
	Если Символ <> """" И Символ <> "'" Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если НЕ ВКавычках Тогда
		ВКавычках = Истина;
		ТипКавычек = Символ;
	Иначе
		Если Символ = ТипКавычек Тогда
			ВКавычках = Ложь;
			ТипКавычек = "";
		КонецЕсли;
	КонецЕсли;
	
	Возврат Истина;
КонецФункции

// Проверяет, является ли двоеточие в указанной позиции разделителем ключ-значение
//
// Параметры:
//   Строка - Строка - исходная строка
//   Позиция - Число - позиция двоеточия
//
// Возвращаемое значение:
//   Булево - Истина, если двоеточие является разделителем
//
Функция ЭтоРазделительДвоеточие(Строка, Позиция)
	// Проверка, что после двоеточия идет пробел или конец строки
	Если Позиция < СтрДлина(Строка) Тогда
		СледующийСимвол = Сред(Строка, Позиция + 1, 1);
		Если СледующийСимвол <> " " И СледующийСимвол <> Символы.Таб Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	
	// Проверка, что перед двоеточием нет пробела
	Если Позиция > 1 Тогда
		ПредыдущийСимвол = Сред(Строка, Позиция - 1, 1);
		Если ПредыдущийСимвол = " " ИЛИ ПредыдущийСимвол = Символы.Таб Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Истина;
КонецФункции
