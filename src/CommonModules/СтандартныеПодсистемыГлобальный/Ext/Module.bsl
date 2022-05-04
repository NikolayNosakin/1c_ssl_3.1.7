﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Продолжает запуск в режиме интерактивного взаимодействия с пользователем.
Процедура ОбработчикОжиданияНачатьИнтерактивнуюОбработкуПередНачаломРаботыСистемы() Экспорт
	
	СтандартныеПодсистемыКлиент.НачатьИнтерактивнуюОбработкуПередНачаломРаботыСистемы();
	
КонецПроцедуры

// Продолжает запуск в режиме интерактивного взаимодействия с пользователем.
Процедура ОбработчикОжиданияПриНачалеРаботыСистемы() Экспорт
	
	СтандартныеПодсистемыКлиент.ПриНачалеРаботыСистемы(, Ложь);
	
КонецПроцедуры

// Продолжает завершение в режиме интерактивного взаимодействия с пользователем
// после установки Отказ = Истина.
//
Процедура ОбработчикОжиданияИнтерактивнаяОбработкаПередЗавершениемРаботыСистемы() Экспорт
	
	СтандартныеПодсистемыКлиент.НачатьИнтерактивнуюОбработкуПередЗавершениемРаботыСистемы();
	
КонецПроцедуры

// Вызывается после запуска конфигурации, открывает окно информации.
Процедура ПоказатьИнформациюПослеЗапуска() Экспорт
	МодульИнформацияПриЗапускеКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("ИнформацияПриЗапускеКлиент");
	МодульИнформацияПриЗапускеКлиент.Показать();
КонецПроцедуры

// Вызывается после запуска конфигурации, открывает окно предупреждения безопасности.
Процедура ПоказатьПредупреждениеБезопасностиПослеЗапуска() Экспорт
	ПользователиСлужебныйКлиент.ПоказатьПредупреждениеБезопасности();
КонецПроцедуры

// Показывает сообщение пользователю о недостаточном объеме оперативной памяти.
Процедура ПоказатьРекомендациюПоОбъемуОперативнойПамяти() Экспорт
	СтандартныеПодсистемыКлиент.ОповеститьОНехваткеПамяти();
КонецПроцедуры

// Отображает всплывающее предупреждение о необходимости выполнения дополнительных
// действий перед завершением работы системы.
//
Процедура ПоказатьПредупрежденияПриЗавершенииРаботы() Экспорт
	Предупреждения = СтандартныеПодсистемыКлиент.ПараметрКлиента("ПредупрежденияПриЗавершенииРаботы");
	Пояснение = НСтр("ru = 'и выполнить дополнительные действия'");
	Если Предупреждения.Количество() = 1 И Не ПустаяСтрока(Предупреждения[0].ТекстГиперссылки) Тогда
		Пояснение = Предупреждения[0].ТекстГиперссылки;
	КонецЕсли;
	ПоказатьОповещениеПользователя(НСтр("ru = 'Нажмите, чтобы завершить работу'"), 
		"e1cib/command/ОбщаяКоманда.ПредупрежденияПриЗавершенииРаботы",
		Пояснение, БиблиотекаКартинок.ЗавершитьРаботу, СтатусОповещенияПользователя.Важное);
КонецПроцедуры

#КонецОбласти
