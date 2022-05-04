﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Вызывается при обработке сообщения http://www.1c.ru/SaaS/RemoteAdministration/App/a.b.c.d}SetFullControl.
//
// Параметры:
//  ПользовательОбластиДанных - СправочникСсылка.Пользователи - пользователь 
//   принадлежность которого к группе Администраторы требуется изменить.
//  ДоступРазрешен - Булево - Истина включить пользователя в группу,
//   Ложь- исключить пользователя из группы.
//
Процедура УстановитьПринадлежностьПользователяКГруппеАдминистраторы(Знач ПользовательОбластиДанных, Знач ДоступРазрешен) Экспорт
	
	ГруппаАдминистраторы = УправлениеДоступом.ГруппаДоступаАдминистраторы();
	
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("Справочник.ГруппыДоступа");
	ЭлементБлокировки.УстановитьЗначение("Ссылка", ГруппаАдминистраторы);
	Блокировка.Заблокировать();
	
	ГруппаОбъект = ГруппаАдминистраторы.ПолучитьОбъект();
	
	СтрокаПользователь = ГруппаОбъект.Пользователи.Найти(ПользовательОбластиДанных, "Пользователь");
	
	Если ДоступРазрешен И СтрокаПользователь = Неопределено Тогда
		
		СтрокаПользователь = ГруппаОбъект.Пользователи.Добавить();
		СтрокаПользователь.Пользователь = ПользовательОбластиДанных;
		ГруппаОбъект.Записать();
		
	ИначеЕсли НЕ ДоступРазрешен И СтрокаПользователь <> Неопределено Тогда
		
		ГруппаОбъект.Пользователи.Удалить(СтрокаПользователь);
		ГруппаОбъект.Записать();
	Иначе
		УправлениеДоступом.ОбновитьРолиПользователей(ПользовательОбластиДанных);
	КонецЕсли;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОчередьЗаданийПереопределяемый.ПриПолученииСпискаШаблонов.
Процедура ПриПолученииСпискаШаблонов(ШаблоныЗаданий) Экспорт
	
	ШаблоныЗаданий.Добавить(Метаданные.РегламентныеЗадания.ЗаполнениеДанныхДляОграниченияДоступа.Имя);
	ШаблоныЗаданий.Добавить(Метаданные.РегламентныеЗадания.ОбновлениеДоступаНаУровнеЗаписей.Имя);
	
КонецПроцедуры

// См. ВыгрузкаЗагрузкаДанныхПереопределяемый.ПослеЗагрузкиДанных.
Процедура ПослеЗагрузкиДанных(Контейнер) Экспорт
	
	// Обновление поставляемых профилей выполняется в регламентном задании
	// ЗаполнениеПараметровРаботыРасширений, которое включается и запускается
	// в процедуре СтандартныеПодсистемыСервер.ПослеЗагрузкиДанных.
	
	УправлениеДоступомСлужебный.ЗапланироватьОбновлениеПараметровОграниченияДоступа(
		"ПослеЗагрузкиДанныхВОбластьДанных");
	
КонецПроцедуры

// Вызывается при обновлении ролей пользователя информационной базы.
//
// Параметры:
//  ИдентификаторПользователяИБ - УникальныйИдентификатор,
//  Отказ - Булево - при установке значения параметра в значение Ложь внутри обработчика события
//    обновление ролей для этого пользователя информационной базы будет пропущено.
//
Процедура ПриОбновленииРолейПользователяИБ(Знач ИдентификаторПользователя, Отказ) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено()
		И ПользователиСлужебныйВМоделиСервиса.ПользовательЗарегистрированКакНеразделенный(ИдентификаторПользователя) Тогда
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
