﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Форма параметризуется:
//
//      Заголовок     - Строка  - заголовок формы.
//      ЗначенияПолей - Строка  - сериализованное значение контактной информации или пустая строка для 
//                                ввода нового.
//      Представление - Строка  - представление адреса (используется только при работе со старыми данными).
//      ВидКонтактнойИнформации - СправочникСсылка.ВидыКонтактнойИнформации, Структура - описание того, что мы
//                                редактируем.
//      Комментарий  - Строка   - необязательный комментарий, для подстановки в поле "Комментарий".
//
//      ВозвращатьСписокЗначений - Булево - необязательный флаг того, что возвращаемое значение поля.
//                                 КонтактнаяИнформация будет иметь тип СписокЗначений (совместимость).
//
//  Результат выбора:
//      Структура - поля:
//          * КонтактнаяИнформация   - Строка - XML контактной информации.
//          * Представление          - Строка - Представление.
//          * Комментарий            - Строка - Комментарий.
//
// -------------------------------------------------------------------------------------------------

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("ВозвращатьСписокЗначений", ВозвращатьСписокЗначений);
	
	// Разбор параметров в реквизиты.
	Если ТипЗнч(Параметры.ВидКонтактнойИнформации) = Тип("СправочникСсылка.ВидыКонтактнойИнформации") Тогда
		ВидКонтактнойИнформации = Параметры.ВидКонтактнойИнформации;
	КонецЕсли;
	
	СтруктураВидКонтактнойИнформации = УправлениеКонтактнойИнформациейСлужебный.СтруктураВидаКонтактнойИнформации(Параметры.ВидКонтактнойИнформации);
	ТипКонтактнойИнформации = СтруктураВидКонтактнойИнформации.Тип;
	
	ПроверятьКорректность = СтруктураВидКонтактнойИнформации.ПроверятьКорректность;
	Заголовок = ?(ПустаяСтрока(Параметры.Заголовок), Строка(ВидКонтактнойИнформации), Параметры.Заголовок);
	ЭтоНовый = Ложь;
	
	ЗначенияПолей = ОпределитьЗначениеАдреса(Параметры);
	
	Если Метаданные.Обработки.Найти("РасширенныйВводКонтактнойИнформации") <> Неопределено Тогда
		
		ПодсказкиПриВводеТелефона = Обработки["РасширенныйВводКонтактнойИнформации"].ПодсказкиПриВводеТелефона();
		Элементы.КодСтраны.ПодсказкаВвода = ПодсказкиПриВводеТелефона.КодСтраны;
		Элементы.КодГорода.ПодсказкаВвода = ПодсказкиПриВводеТелефона.КодГорода;
		Элементы.НомерТелефона.ПодсказкаВвода = ПодсказкиПриВводеТелефона.НомерТелефона;		
		
		ИспользоватьДополнительныеПроверки = Истина;
		
	КонецЕсли;
	
	Если ПустаяСтрока(ЗначенияПолей) Тогда
		Данные = УправлениеКонтактнойИнформацией.ОписаниеНовойКонтактнойИнформации(ТипКонтактнойИнформации);
		ЭтоНовый = Истина;
	ИначеЕсли УправлениеКонтактнойИнформациейКлиентСервер.ЭтоКонтактнаяИнформацияВJSON(ЗначенияПолей) Тогда
		Данные = УправлениеКонтактнойИнформациейСлужебный.JSONВКонтактнуюИнформациюПоПолям(ЗначенияПолей, Перечисления.ТипыКонтактнойИнформации.Телефон);
	Иначе
		
		Если УправлениеКонтактнойИнформациейСлужебныйПовтИсп.ДоступенМодульЛокализации() Тогда
			МодульУправлениеКонтактнойИнформациейЛокализация = ОбщегоНазначения.ОбщийМодуль("УправлениеКонтактнойИнформациейЛокализация");
		
			Если УправлениеКонтактнойИнформациейКлиентСервер.ЭтоКонтактнаяИнформацияВXML(ЗначенияПолей) Тогда
				РезультатыЧтения = Новый Структура;
				КонтактнаяИнформация = МодульУправлениеКонтактнойИнформациейЛокализация.КонтактнаяИнформацияИзXML(ЗначенияПолей, ТипКонтактнойИнформации, РезультатыЧтения);
				Если РезультатыЧтения.Свойство("ТекстОшибки") Тогда
					// Распознали с ошибками, сообщим при открытии.
					ТекстПредупрежденияПриОткрытии = РезультатыЧтения.ТекстОшибки;
					КонтактнаяИнформация.Представление = Параметры.Представление;
				КонецЕсли;
					
				Иначе
					Если ТипКонтактнойИнформации = Перечисления.ТипыКонтактнойИнформации.Телефон Тогда
						КонтактнаяИнформация = МодульУправлениеКонтактнойИнформациейЛокализация.ДесериализацияТелефона(ЗначенияПолей, Параметры.Представление, ТипКонтактнойИнформации);
					Иначе
						КонтактнаяИнформация = МодульУправлениеКонтактнойИнформациейЛокализация.ДесериализацияФакса(ЗначенияПолей, Параметры.Представление, ТипКонтактнойИнформации);
					КонецЕсли;
			КонецЕсли;
			
			Данные = УправлениеКонтактнойИнформациейСлужебный.КонтактнаяИнформацияВСтруктуруJSON(КонтактнаяИнформация, ТипКонтактнойИнформации);
		Иначе
			Данные = УправлениеКонтактнойИнформацией.ОписаниеНовойКонтактнойИнформации(ТипКонтактнойИнформации);
		КонецЕсли;
		
	КонецЕсли;
	
	ЗначениеРеквизитовПоКонтактнойИнформации(Данные);
	
	Элементы.Добавочный.Видимость = СтруктураВидКонтактнойИнформации.ТелефонCДобавочнымНомером;
	Элементы.ОчиститьТелефон.Доступность = Не Параметры.ТолькоПросмотр;
	
	Коды = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("Обработка.ВводКонтактнойИнформации.Форма.ВводТелефона", "КодыСтраныИГорода");
	Если ТипЗнч(Коды) = Тип("Структура") Тогда
		Если ЭтоНовый Тогда
				Коды.Свойство("КодСтраны", КодСтраны);
				Коды.Свойство("КодГорода", КодГорода);
		КонецЕсли;
		
		Если Коды.Свойство("СписокКодовГорода") Тогда
			Элементы.КодГорода.СписокВыбора.ЗагрузитьЗначения(Коды.СписокКодовГорода);
		КонецЕсли;
	КонецЕсли;
	
	Если СтруктураВидКонтактнойИнформации.ХранитьИсториюИзменений Тогда
		Если Параметры.Свойство("КонтактнаяИнформацияОписаниеДополнительныхРеквизитов") Тогда
			Для каждого СтрокаКИ Из Параметры.КонтактнаяИнформацияОписаниеДополнительныхРеквизитов Цикл
				НоваяСтрока = КонтактнаяИнформацияОписаниеДополнительныхРеквизитов.Добавить();
				ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаКИ);
			КонецЦикла;
		КонецЕсли;
	КонецЕсли;
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		
		ПоложениеКоманднойПанели = ПоложениеКоманднойПанелиФормы.Авто;
		
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "Представление", "ПодсказкаВвода", НСтр("ru = 'Представление'"));
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "КомандаОК", "Картинка", БиблиотекаКартинок.ЗаписатьИЗакрыть);
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "КомандаОК", "Отображение", ОтображениеКнопки.Картинка);
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "Отмена", "Видимость", Ложь);
		
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "КодСтраны", "ПоложениеЗаголовка", ПоложениеЗаголовкаЭлементаФормы.Лево);
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "КодГорода", "ПоложениеЗаголовка", ПоложениеЗаголовкаЭлементаФормы.Лево);
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "НомерТелефона", "ПоложениеЗаголовка", ПоложениеЗаголовкаЭлементаФормы.Лево);
		ОбщегоНазначенияКлиентСервер.УстановитьСвойствоЭлементаФормы(Элементы, "Добавочный", "ПоложениеЗаголовка", ПоложениеЗаголовкаЭлементаФормы.Лево);
		
		Если Элементы.КодГорода.СписокВыбора.Количество() < 2 Тогда
			
			Элементы.КодГорода.КнопкаВыпадающегоСписка = Неопределено;
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если Не ПустаяСтрока(ТекстПредупрежденияПриОткрытии) Тогда
		ПодключитьОбработчикОжидания("Подключаемый_ПредупредитьПослеОткрытияФормы", 0.1, Истина);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(КодГорода) Тогда
		ТекущийЭлемент = Элементы.КодГорода;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	
	Оповещение = Новый ОписаниеОповещения("ПодтвердитьИЗакрыть", ЭтотОбъект);
	ОбщегоНазначенияКлиент.ПоказатьПодтверждениеЗакрытияФормы(Оповещение, Отказ, ЗавершениеРаботы);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура КодСтраныПриИзменении(Элемент)
	
	ЗаполнитьПредставлениеТелефона();
	
КонецПроцедуры

&НаКлиенте
Процедура КодГородаПриИзменении(Элемент)
	
	Если ИспользоватьДополнительныеПроверки Тогда
	
		МодульРаботаСАдресамиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаСАдресамиКлиент");
		МодульРаботаСАдресамиКлиент.ПоказатьПодсказкуКорректностиКодовСтраныИГорода(КодСтраны, КодГорода);
		
	КонецЕсли;
	
	ЗаполнитьПредставлениеТелефона();
КонецПроцедуры

&НаКлиенте
Процедура НомерТелефонаПриИзменении(Элемент)
	
	ЗаполнитьПредставлениеТелефона();
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавочныйПриИзменении(Элемент)
	
	ЗаполнитьПредставлениеТелефона();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаОК(Команда)
	ПодтвердитьИЗакрыть();
КонецПроцедуры

&НаКлиенте
Процедура КомандаОтмена(Команда)
	
	Модифицированность = Ложь;
	Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьТелефон(Команда)
	
	ОчиститьТелефонСервер();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура Подключаемый_ПредупредитьПослеОткрытияФормы()
	
	ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстПредупрежденияПриОткрытии);
	
КонецПроцедуры

&НаКлиенте
Процедура ПодтвердитьИЗакрыть(Результат = Неопределено, ДополнительныеПараметры = Неопределено) Экспорт
	
	// При немодифицированности работает "отмена".
	
	Если Модифицированность Тогда
		
		ЕстьОшибкиЗаполнения = Ложь;
		// Смотрим, надо ли проверять на корректность.
		Если ПроверятьКорректность Тогда
			
			МодульРаботаСАдресамиКлиент = Неопределено;
			Если ИспользоватьДополнительныеПроверки Тогда
				МодульРаботаСАдресамиКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаСАдресамиКлиент");
			КонецЕсли;

			ПоляТелефона = УправлениеКонтактнойИнформациейКлиентСервер.СтруктураПолейТелефона();
			ПоляТелефона.КодГорода     = КодГорода;
			ПоляТелефона.КодСтраны     = КодСтраны;
			ПоляТелефона.НомерТелефона = НомерТелефона;
			ПоляТелефона.Представление = Представление;
			ПоляТелефона.Добавочный    = Добавочный;
			ПоляТелефона.Комментарий   = Комментарий;
			
			СписокОшибок = УправлениеКонтактнойИнформациейКлиентСервер.ОшибкиЗаполненияТелефона(ПоляТелефона, МодульРаботаСАдресамиКлиент);
			
			ЕстьОшибкиЗаполнения = СписокОшибок.Количество() > 0;
		КонецЕсли;
		Если ЕстьОшибкиЗаполнения Тогда
			СообщитьОбОшибкахЗаполнения(СписокОшибок);
			Возврат;
		КонецЕсли;
		
		Результат = РезультатВыбора();
	
		СброситьМодифицированностьПриВыборе();
		ОповеститьОВыборе(Результат);
		
	ИначеЕсли Комментарий <> КопияКомментария Тогда
		// Изменен только комментарий, пробуем вернуть обновленное.
		Результат = РезультатВыбораТолькоКомментария();
		
		СброситьМодифицированностьПриВыборе();
		ОповеститьОВыборе(Результат);
		
	Иначе
		Результат = Неопределено;
		
	КонецЕсли;
	
	Если (МодальныйРежим Или ЗакрыватьПриВыборе) И Открыта() Тогда
		СброситьМодифицированностьПриВыборе();
		Закрыть(Результат);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СброситьМодифицированностьПриВыборе()
	
	Модифицированность = Ложь;
	КопияКомментария   = Комментарий;
	
КонецПроцедуры

&НаСервере
Функция РезультатВыбора()
	
	Результат = Новый Структура();
	
	СписокВыбора = Элементы.КодГорода.СписокВыбора;
	ЭлементСписка = СписокВыбора.НайтиПоЗначению(КодГорода);
	Если ЭлементСписка = Неопределено Тогда
		СписокВыбора.Вставить(0, КодГорода);
		Если СписокВыбора.Количество() > 10 Тогда
			СписокВыбора.Удалить(10);
		КонецЕсли;
	Иначе
		Индекс = СписокВыбора.Индекс(ЭлементСписка);
		Если Индекс <> 0 Тогда
			СписокВыбора.Сдвинуть(Индекс, -Индекс);
		КонецЕсли;
	КонецЕсли;
	
	Коды = Новый Структура("КодСтраны, КодГорода, СписокКодовГорода", КодСтраны, КодГорода, СписокВыбора.ВыгрузитьЗначения());
	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить("Обработка.ВводКонтактнойИнформации.Форма.ВводТелефона", "КодыСтраныИГорода", Коды, НСтр("ru = 'Коды страны и города'"));
	
	КонтактнаяИнформация = КонтактнаяИнформацияПоЗначениюРеквизитов();
	
	ДанныеВыбора = УправлениеКонтактнойИнформациейСлужебный.СтруктураВСтрокуJSON(КонтактнаяИнформация);
	
	Результат.Вставить("Вид", ВидКонтактнойИнформации);
	Результат.Вставить("Тип", ТипКонтактнойИнформации);
	Результат.Вставить("КонтактнаяИнформация", УправлениеКонтактнойИнформацией.КонтактнаяИнформацияВXML(ДанныеВыбора, КонтактнаяИнформация.Value, ТипКонтактнойИнформации));
	Результат.Вставить("Значение", ДанныеВыбора);
	Результат.Вставить("Представление", КонтактнаяИнформация.Value);
	Результат.Вставить("Комментарий", КонтактнаяИнформация.Comment);
	Результат.Вставить("ВВидеГиперссылки", Ложь);
	Результат.Вставить("КонтактнаяИнформацияОписаниеДополнительныхРеквизитов",
		КонтактнаяИнформацияОписаниеДополнительныхРеквизитов);
	
	Возврат Результат
КонецФункции

&НаСервере
Функция РезультатВыбораТолькоКомментария()
	
	КонтактнаяИнфо = ОпределитьЗначениеАдреса(Параметры);
	Если ПустаяСтрока(КонтактнаяИнфо) Тогда
		
		Если УправлениеКонтактнойИнформациейСлужебныйПовтИсп.ДоступенМодульЛокализации() Тогда
			МодульУправлениеКонтактнойИнформациейЛокализация = ОбщегоНазначения.ОбщийМодуль("УправлениеКонтактнойИнформациейЛокализация");
		
			Если ТипКонтактнойИнформации = Перечисления.ТипыКонтактнойИнформации.Телефон Тогда
				КонтактнаяИнфо = МодульУправлениеКонтактнойИнформациейЛокализация.ДесериализацияТелефона("", "", ТипКонтактнойИнформации);
			Иначе
				КонтактнаяИнфо = МодульУправлениеКонтактнойИнформациейЛокализация.ДесериализацияФакса("", "", ТипКонтактнойИнформации);
			КонецЕсли;
			УправлениеКонтактнойИнформацией.УстановитьКомментарийКонтактнойИнформации(КонтактнаяИнфо, Комментарий);
			КонтактнаяИнфо = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияВXML(КонтактнаяИнфо);
		КонецЕсли;
		
	ИначеЕсли УправлениеКонтактнойИнформациейКлиентСервер.ЭтоКонтактнаяИнформацияВXML(КонтактнаяИнфо) Тогда
		УправлениеКонтактнойИнформацией.УстановитьКомментарийКонтактнойИнформации(КонтактнаяИнфо, Комментарий);
	КонецЕсли;
	
	Возврат Новый Структура("КонтактнаяИнформация, Представление, Комментарий",
		КонтактнаяИнфо, Параметры.Представление, Комментарий);
КонецФункции

// Заполняет реквизиты формы из XTDO объекта типа "Контактная информация".
&НаСервере
Процедура ЗначениеРеквизитовПоКонтактнойИнформации(РедактируемаяИнформация)
	
	// Общие реквизиты
	Представление = РедактируемаяИнформация.Value;
	Комментарий   = РедактируемаяИнформация.Comment;
	
	// Копия комментария для анализа измененности.
	КопияКомментария = Комментарий;
	
	КодСтраны     = РедактируемаяИнформация.CountryCode;
	КодГорода     = РедактируемаяИнформация.AreaCode;
	НомерТелефона = РедактируемаяИнформация.Number;
	Добавочный    = РедактируемаяИнформация.ExtNumber;
	
КонецПроцедуры

// Возвращает XTDO объект типа "Контактная информация" по значению реквизитов.
&НаСервере
Функция КонтактнаяИнформацияПоЗначениюРеквизитов()
	
	Результат = УправлениеКонтактнойИнформациейКлиентСервер.ОписаниеНовойКонтактнойИнформации(ТипКонтактнойИнформации);
	
	Результат.CountryCode = КодСтраны;
	Результат.AreaCode    = КодГорода;
	Результат.Number      = НомерТелефона;
	Результат.ExtNumber   = Добавочный;
	Результат.Value       = УправлениеКонтактнойИнформациейКлиентСервер.СформироватьПредставлениеТелефона(КодСтраны, КодГорода, НомерТелефона, Добавочный, "");
	Результат.Comment     = Комментарий;
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Процедура ЗаполнитьПредставлениеТелефона()
	
	ПодключитьОбработчикОжидания("ЗаполнитьПредставлениеТелефонаСейчас", 0.1, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьПредставлениеТелефонаСейчас()
	
	Представление = УправлениеКонтактнойИнформациейКлиентСервер.СформироватьПредставлениеТелефона(КодСтраны, 
		КодГорода, НомерТелефона, Добавочный, "");
	
КонецПроцедуры

// Сообщает об ошибках заполнения по результату функции ОшибкиЗаполненияТелефонаСервер.
&НаКлиенте
Процедура СообщитьОбОшибкахЗаполнения(СписокОшибок)
	
	Если СписокОшибок.Количество()=0 Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Телефон введен корректно.'"));
		Возврат;
	КонецЕсли;
	
	ОчиститьСообщения();
	
	// Значение - XPath, представление - описание ошибки.
	Для Каждого Элемент Из СписокОшибок Цикл
		ОбщегоНазначенияКлиент.СообщитьПользователю(Элемент.Представление,,,
		ПутьКДаннымФормыПоПутиXPath(Элемент.Значение));
	КонецЦикла;
	
КонецПроцедуры    

&НаКлиенте 
Функция ПутьКДаннымФормыПоПутиXPath(ПутьXPath) 
	Возврат ПутьXPath;
КонецФункции

&НаСервере
Процедура ОчиститьТелефонСервер()
	КодСтраны     = "";
	КодГорода     = "";
	НомерТелефона = "";
	Добавочный    = "";
	Комментарий   = "";
	Представление = "";
	
	Модифицированность = Истина;
КонецПроцедуры

&НаСервере
Функция ОпределитьЗначениеАдреса(Параметры)
	
	Если Параметры.Свойство("Значение") Тогда
		Если ПустаяСтрока(Параметры.Значение) И ЗначениеЗаполнено(Параметры.ЗначенияПолей) Тогда
			ЗначенияПолей = Параметры.ЗначенияПолей;
		Иначе
			ЗначенияПолей = Параметры.Значение;
		КонецЕсли;
	Иначе
		ЗначенияПолей = Параметры.ЗначенияПолей;
	КонецЕсли;
	Возврат ЗначенияПолей;

КонецФункции

#КонецОбласти
