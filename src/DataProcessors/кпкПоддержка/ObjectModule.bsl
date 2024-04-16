 Перем МаксимальныйРазмерФайлаВложения;
 Перем АдресТехПоддержки;
 
 //////////////////////////////////////////////////////////////////////////////////
 // ПРОЦЕДУРЫ И ФУНКЦИИ СПЕЦИАЛЬНОГО НАЗНАЧЕНИЯ
 //////////////////////////////////////////////////////////////////////////////////
 
#Если Клиент Тогда
 
////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ СОЗДАНИЯ ЭЛЕКТРОННОГО ПИСЬМА В СЛУЖБУ ТЕХПОДДЕРЖКИ

// Функция корректно обрезает имя файла если оно  больше 100 символов, 
// чтобы осталось расширение. (рфОбрезатьИмяФайла("ОченьДлинноеИмяФайла.txt",20) -> ОченьДлинноеИмяФ.txt)
//
// Параметры
//  ИмяФайла 		   – Строка, содержащая имя файла, неважно с именем каталога или без.
//  КоличествоСимволов – Число, кол-во символов, до которого необходимо урезать имя файла.
//  ВыводитьСообщение  – Булево, признак необходимости вывести сообщение что имя файла обрезано.
//
// Возвращаемое значение:
//  Строка   – обрезанное имя файла.
//
Функция ОбрезатьИмяФайла(Знач ИмяФайла, КоличествоСимволов, ВыводитьСообщение=Ложь) Экспорт
	
	Если СтрДлина(ИмяФайла) > КоличествоСимволов Тогда
		Если ВыводитьСообщение Тогда
			Сообщить("Имя файла """+ИмяФайла+""" обрезано, так как его длина больше "+КоличествоСимволов+" символов", СтатусСообщения.Информация);
		КонецЕсли; 
		РасширениеФайла = РаботаСФайлами.ПолучитьРасширениеФайла(ИмяФайла);
		СамоИмяФайла = Лев(ИмяФайла, СтрДлина(ИмяФайла)-СтрДлина(РасширениеФайла)-1);
		СамоИмяФайла = Лев(СамоИмяФайла, КоличествоСимволов-СтрДлина(РасширениеФайла)-1);
		ИмяФайла = СамоИмяФайла + "." + РасширениеФайла;
	КонецЕсли;
	
	Возврат ИмяФайла;
	
КонецФункции // рфОбрезатьИмяФайла()

// Добавляет переданные файлы во вложение
// Параметры
//  ТаблицаВложенныхФайлов         - ТаблицаЗначений - таблица значений документа "Электронное письмо".
//  ИмяФайла                       - Строка - полное имя файла-вложения, существующего на диске. 
//  НаименованиеФайла              - Строка - описание файла-вложения
//  УдалятьФайлПослеДобавления     - Булево - признак нужно ли удалить переданный файл после добавления в письмо
//                                   Внимание!! Файл будет удален независимо от того, удалась отправка письма или нет
//  ЗадаватьВопросДляБольшогоФайла - Булево - признак, нужно ли задавать вопрос на добавление файла больше 25 мб
//
Процедура ДобавитьВложениеВПисьмо(ТаблицаВложенныхФайлов, ИмяФайла, НаименованиеФайла = "", УдалятьФайлыПослеДобавления = Ложь) Экспорт
	
	Файл = Новый Файл(ИмяФайла);
	ИмяФайла = РаботаСФайлами.ПолучитьИмяФайлаИзПолногоПути(ИмяФайла);
	
	Если Файл.Размер() > МаксимальныйРазмерФайлаВложения Тогда
		#Если Клиент Тогда 
		Ответ = Вопрос("Размер добавляемого файла """ + ИмяФайла + """
					   |превышает максимальный. Добавить ?", РежимДиалогаВопрос.ДаНет,,КодВозвратаДиалога.Нет,"Внимание!");
		Если Ответ = КодВозвратаДиалога.Нет Тогда
			Возврат;
		КонецЕсли; 
		#КонецЕсли
	КонецЕсли; 
	НоваяСтрока = ТаблицаВложенныхФайлов.Добавить();
	НоваяСтрока.ИмяФайла = ОбрезатьИмяФайла(ИмяФайла, 100, Истина);
	НоваяСтрока.Наименование = НаименованиеФайла;
	#Если Клиент Тогда 
	Состояние("Добавляется файл: " + НоваяСтрока.ИмяФайла);
	#КонецЕсли
	НоваяСтрока.Данные = Новый ХранилищеЗначения(Новый ДвоичныеДанные(Файл.ПолноеИмя), Новый СжатиеДанных());
	
	Если УдалятьФайлыПослеДобавления Тогда
		Попытка
			УдалитьФайлы(ИмяФайла);
		Исключение
			Сообщить("Не удалось удалить файл: " +	ИмяФайла);
		КонецПопытки
	КонецЕсли;	

КонецПроцедуры // эпДобавитьВложенияВПисьмо()

// Процедура формирует электронное письмо в службу техподдержки. Расставляет необходимые комментарии,
// получает информацию о системе, о текущем объекте, о системе защиты и т.д. 
//
// Параметры
//  ЭтаФорма - "Форма" - если формирование письма вызвано из меню "Действия", то
//  					 эта переменная содержит текущую форму.
//
//  Ссылка - "ЛюбаяСсылка" - если формирование письма вызвано в форме списка, то данная
//							 переменная содержит ссылку на текщий объект.
//
// Возвращаемое значение:
//   НЕТ
// 
Процедура НаписатьПисьмоВСлужбуТехПоддержки(ЭтаФорма=Неопределено, Ссылка=Неопределено) Экспорт 
	
	НовоеПисьмо = Документы.ЭлектронноеПисьмо.СоздатьДокумент();
	СписокУчетныхЗаписей = НовоеПисьмо.мСтруктураДоступа.Запись.Скопировать();
	Если СписокУчетныхЗаписей.Количество() > 0 Тогда
		НовоеПисьмо.УчетнаяЗапись = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(ПараметрыСеанса.ТекущийПользователь, "ОсновнаяУчетнаяЗапись");
		Если НЕ ЗначениеЗаполнено(НовоеПисьмо.УчетнаяЗапись) Тогда
			УчетнаяЗапись = СписокУчетныхЗаписей[0].Значение;
		КонецЕсли;
	Иначе
		Предупреждение("У вас нет прав создавать и отправлять письма ни с одной учетной записи.");
		Возврат
	КонецЕсли;	

	СтрокаПолучателя = НовоеПисьмо.КомуТЧ.Добавить();
	СтрокаПолучателя.Представление = "Служба техподдержки ""Агент Плюс""";
	
	СтрокаПолучателя.АдресЭлектроннойПочты = АдресТехПоддержки;
	НовоеПисьмо.Кому = АдресТехПоддержки;
	
	НовоеПисьмо.ВидТекстаПисьма = Перечисления.ВидыТекстовЭлектронныхПисем.Текст;
	
	Текст = "/ЗДЕСЬ НЕОБХОДИМО  ПОДРОБНО ОПИСАТЬ СУТЬ
	|ПРОБЛЕМЫ ИЛИ ПРЕДЛОЖЕНИЯ. ПИСЬМА БЕЗ ДЕТАЛЬНОГО ОПИСАНИЯ БУДУТ ИГНОРИРОВАНЫ/";	
	
	// Оставляем место для текста пользователя
	Для Сч=0 По 5 Цикл
		Текст = Текст + Символы.ПС;	
	КонецЦикла;
	
	ФормаНовогоПисьма = НовоеПисьмо.ПолучитьФорму();
	
	Ответ = Вопрос("Добавить в письмо информацию о системе?", РежимДиалогаВопрос.ДаНет,, КодВозвратаДиалога.Да);
	
	Если Ответ = КодВозвратаДиалога.Да Тогда
		Текст = Текст + "/БЛОК ИНФОРМАЦИИ О СИСТЕМЕ, СОБРАННОЙ 
		|АВТОМАТИЧЕСКИ. УБЕДИТЕЛЬНО ПРОСИМ НЕ УДАЛЯТЬ 
		|СОБРАННЫЕ СИСТЕМОЙ СВЕДЕНИЯ, ЗА ИСКЛЮЧЕНИЕМ ТЕХ, КОТОРЫЕ 
		|ВЫ СОЧТЕТЕ СЕКРЕТНЫМИ. КОМПАНИЯ РАЗРАБОТЧИК ОБЯЗУЕТСЯ 
		|СОХРАНЯТЬ КОНФИДЕНЦИАЛЬНОСТЬ ВСЕЙ ПОЛУЧЕННОЙ ИНФОРМАЦИИ./";
		
		// Получаем информацию о программе стандартными методами 1С
		Текст = Текст + Символы.ПС;
		Текст = Текст + Символы.ПС;	
		Текст = Текст + "ИНФОРМАЦИЯ О ПРОГРАММЕ:";
		Текст = Текст + Символы.ПС;	
		Текст = Текст + ПолучитьИнформациюОПрограмме();
		//      		
				
		// 5. Теперь журнал регистрации за сутки выгрузим.
		Состояние("Выгрузка журнала регистрации...");
		ИмяФайла = ВыгрузитьЖурналРегистрацииВПисьмо();
		Если ИмяФайла<>"" Тогда
			ДобавитьВложениеВПисьмо(ФормаНовогоПисьма.ВложенияПисьмаТЗ, ИмяФайла, "Выгрузка из журнала регистрации за ближайшие сутки",Истина); // Прикрепляем файл к письму и удаляем его.	
		КонецЕсли;
		
	КонецЕсли;	
	
	НовоеПисьмо.ТекстПисьма = Текст;
	ФормаНовогоПисьма.Открыть();  		
	
КонецПроцедуры // элНаписатьПисьмоВСлужбуТехПоддержки()
                
// Функция получает необходимую информацию о программе.
//
// Параметры
//  НЕТ
//
// Возвращаемое значение:
//   Строка - информация о программе.
//
Функция ПолучитьИнформациюОПрограмме()
	Текст = "";
	Текст = Текст + "Конфигурация: " + Метаданные.Имя  + " (" + Метаданные.Синоним + ")";	
	Текст = Текст + Символы.ПС;	
	Текст = Текст + "Поставщик: " + Метаданные.Поставщик;
	Текст = Текст + Символы.ПС;	
	Текст = Текст + "Версия: " + Метаданные.Версия;	
	Текст = Текст + Символы.ПС;	
	Текст = Текст + "Пользователь: " + ИмяПользователя();	 	
	Текст = Текст + Символы.ПС;	
	Текст = Текст + "Полное имя пользователя: " + ПолноеИмяПользователя();
	Текст = Текст + Символы.ПС;	
	Текст = Текст + "Имя компьютера: " + ИмяКомпьютера();
	Текст = Текст + Символы.ПС;	
	Текст = Текст + "Каталог программы: " + КаталогПрограммы();
	Текст = Текст + Символы.ПС;	
	Текст = Текст + "Каталог временных файлов: " + КаталогВременныхФайлов();    
	Текст = Текст + Символы.ПС;	
	Текст = Текст + "Код локализации: " + КодЛокализации();
	Текст = Текст + Символы.ПС;	
	Текст = Текст + "Строка соединения ИБ: " + СтрокаСоединенияИнформационнойБазы(); 
	
	Возврат Текст;
КонецФункции // элПолучитьИнформациюОПрограмме()

Функция ВыгрузитьЖурналРегистрацииВПисьмо(Параметры=Неопределено)
	
	ИмяВыходногоФайла = КаталогВременныхФайлов() + "ЖурналРегистрации.xml";
	
	Фильтр = Новый Структура;
	
	// Попробуем получить фильтр
	Если ТипЗнч(Параметры) = Тип("Структура") Тогда	
		Если Параметры.Свойство("Фильтр") Тогда
			Фильтр = Параметры.Фильтр;
		КонецЕсли;      		
	КонецЕсли;
	
	// Теперь установим некоторые условия фильтра принудительно, если они не были заданы.
	Если Не Фильтр.Свойство("ДатаНачала") Тогда
		Фильтр.Вставить("ДатаНачала", НачалоДня(ТекущаяДата()));
	КонецЕсли;
	
	Если Не Фильтр.Свойство("ДатаОкончания") Тогда
		Фильтр.Вставить("ДатаОкончания", ТекущаяДата());			
	КонецЕсли;
	
	Если Не Фильтр.Свойство("Уровень") Тогда
		мсвУровней = Новый Массив;
		мсвУровней.Добавить(УровеньЖурналаРегистрации.Ошибка);
		мсвУровней.Добавить(УровеньЖурналаРегистрации.Предупреждение);
		Фильтр.Вставить("Уровень", мсвУровней);			
	КонецЕсли;
	
	Если Не Фильтр.Свойство("Пользователь") Тогда
		Фильтр.Вставить("Пользователь", ПользователиИнформационнойБазы.ТекущийПользователь());			
	КонецЕсли;   	
	
	Попытка
		ВыгрузитьЖурналРегистрации(ИмяВыходногоФайла, Фильтр);
		Возврат ИмяВыходногоФайла;
	Исключение
		Сообщить("Ошибка при выгрузке журнала регистрации: " + ОписаниеОшибки());
		Возврат "";
	КонецПопытки;
	
КонецФункции // ВыгрузитьЖурналРегистрацииВПисьмо()

#КонецЕсли

//////////////////////////////////////////////////////////////////////////////////
// ИСПОЛНЯЕМАЯ ЧАСТЬ МОДУЛЯ
//////////////////////////////////////////////////////////////////////////////////

МаксимальныйРазмерФайлаВложения = 4194304;
АдресТехПоддержки = "support@agentplus.ru";