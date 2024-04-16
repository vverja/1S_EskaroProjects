////////////////////////////////////////////////////////////////////////////////
//
// Процедура ВаловаяПрибыль
//
// Описание:
//
//
// Параметры (название, тип, дифференцированное значение)
//
Процедура ВаловаяПрибыль() Экспорт 
    Элемент = Справочники.ВнешниеОбработки.НайтиПоНаименованию("Валовая прибыль (регл. учет)");
	ОткрытьОбработку(Элемент);	
КонецПроцедуры //ВаловаяПрибыль

Процедура КредиторскаяЗадолженностьПоСрокамДолга() Экспорт
	Элемент = Справочники.ВнешниеОбработки.НайтиПоНаименованию("Кредиторская задолженность по срокам долга");
	ОткрытьОбработку(Элемент);
 		
КонецПроцедуры

Процедура ОткрытьОбработку(Элемент)
	Если Не ЗначениеЗаполнено(Элемент) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не найден отчет!";
		Сообщение.Сообщить(); 
	Иначе
		ИмяФайлаОтчета = ПолучитьИмяВременногоФайла("erf"); 
		ДвоичныеДанные = Элемент.ХранилищеВнешнейОбработки.Получить();  
		ДвоичныеДанные.Записать(ИмяФайлаОтчета); 
		//ТекОтчет = ВнешниеОтчеты.Создать(ИмяФайлаОтчета);
		ТекФорма=ВнешниеОтчеты.ПолучитьФорму(ИмяФайлаОтчета);
		//Настройки = ТекОтчет.КомпоновщикНастроек.ПолучитьНастройки();
		//ТекФорма.ОтчетОбъект.КомпоновщикНастроек.ЗагрузитьНастройки(Настройки);
		//ТекФорма.СкомпоноватьРезультат(ТекФорма.РезультатОтчета);
		ТекФорма.Открыть();
		УдалитьФайлы(ИмяФайлаОтчета);
	КонецЕсли;

КонецПроцедуры
 
 
Процедура ПросроченнаяКредиторскаяЗадолженностьПоСрокамДолга() Экспорт
	Элемент = Справочники.ВнешниеОбработки.НайтиПоНаименованию("Просроченная кредиторская задолженность по срокам долга");
	ОткрытьОбработку(Элемент);
КонецПроцедуры

Процедура ВедомостьАмортизацииОС() Экспорт
	Элемент = Справочники.ВнешниеОбработки.НайтиПоНаименованию("Ведомость амортизации ОС (расшифровка к фин. отчету)");
	ОткрытьОбработку(Элемент);
КонецПроцедуры
 
Процедура ВедомостьАмортизацииНМА() Экспорт
	Элемент = Справочники.ВнешниеОбработки.НайтиПоНаименованию("Ведомость амортизации НМА (расшифровка к фин. отчету)");
	ОткрытьОбработку(Элемент);
КонецПроцедуры

Процедура ПечатнаяФормаПоФинансовымОтчетам() Экспорт
	Элемент = Справочники.ВнешниеОбработки.НайтиПоНаименованию("Печатная форма по финансовым отчетам");
	ОткрытьОбработку(Элемент);		
КонецПроцедуры
 