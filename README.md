
# Домашнее задание к занятию «Использование Terraform в команде»

1. **Проверьте код с помощью tflint и checkov. Вам не нужно инициализировать этот проект.**

   **Перечислите какие типы ошибок обнаружены в проекте (без дублей).**
   
   Ответ:  
   Ошибки **tflint**:
   - Module source "..." uses a default branch as ref (main)
   - Missing version constraint for provider "..." in "..."
   - variable "..." is declared but not used
   
   Ошибки **checkov**:
   - CKV_YC_4: "Ensure compute instance does not have serial console enabled." - **не обнаружена**
   - CKV_YC_2: "Ensure compute instance does not have public IP." - **обнаружена**
   - CKV_YC_11: "Ensure security group is assigned to network interface." - **обнаружена**
   - CKV_YC_19: "Ensure security group does not contain allow-all rules." - **не обнаружена**
   
2. **Повторите демонстрацию лекции: настройте YDB, S3 bucket, yandex service account, права доступа и мигрируйте State проекта в S3 с блокировками. Предоставьте скриншоты процесса в качестве ответа.**

   Настройка сервисного эккаунта:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Screenshot%20at%202023-06-03%2017-31-15.png)

   Настройка доступа к корзине:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Screenshot%20at%202023-06-03%2017-32-34.png)

   Переинициализация бекенда:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Screenshot%20at%202023-06-03%2017-35-29.png)

   Создание БД для записи блокировок:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Screenshot%20at%202023-06-03%2018-55-27.png)

   Миграция на конфигурацию с блокировками:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Screenshot%20at%202023-06-03%2019-38-24.png)

   Записи блокировок в БД:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Screenshot%20at%202023-06-03%2019-39-10.png)

   **Откройте в проекте terraform console, а в другом окне из этой же директории попробуйте запустить terraform apply.**
   **Пришлите ответ об ошибке доступа к State.**

   Ошибка **terraform apply** при заблокированной БД:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Screenshot%20at%202023-06-03%2019-39-42.png)

   **Принудительно разблокируйте State. Пришлите команду и вывод.**

   Принудительное снятие блокировки:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Screenshot%20at%202023-06-03%2019-41-39.png)
   
3. **Пришлите ссылку на PR для ревью(вливать код в 'terraform-05' не нужно).**

   Ссылка на [Pull request](https://github.com/fedor-metsger/ter-homeworks/pull/1).
   
   В PR есть один конфликт в одном файле! Но он больше похож на какой то глюк гитхаба, так как выглядит выродженным,
   или сделанным на пустом месте. Вернее пустое место конфликтует с удалением строк (вследствие чего, собственно,
   и образовалось пустое место). Прилагаю скрин:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Screenshot%20at%202023-06-04%2016-50-21.png)
   
   Конфликт я разрешил.
   
4. **Напишите переменные с валидацией и протестируйте их, заполнив default верными и неверными значениями. Предоставьте скриншоты проверок:**

   **type=string, description="ip-адрес", проверка что значение переменной содержит верный IP-адрес с помощью функций cidrhost() или regex(). Тесты: "192.168.0.1" и "1920.1680.0.1"**
   
   Переменные описаны [здесь](https://github.com/fedor-metsger/ter-homeworks/blob/5dc4716c536fc23c134d9d1502c4fdd58529f0ac/04/src/variables.tf#L23).
   
   Прилагаю скриншот ошибки:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Screenshot%20at%202023-06-03%2021-36-27.png)
   
   **type=list(string), description="список ip-адресов", проверка что все адреса верны. Тесты: ["192.168.0.1", "1.1.1.1", "127.0.0.1"] и ["192.168.0.1", "1.1.1.1", "1270.0.0.1"]**
   
   Прилагаю скриншот ошибки:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Screenshot%20at%202023-06-03%2021-55-31.png)
   
5. **Напишите переменные с валидацией:**

   **type=string, description="любая строка", проверка что строка не содержит в себе символов верхнего регистра**
   
   **type=object, проверка что введено только одно из опциональных значений по примеру:**
   
   Переменные описаны [здесь](https://github.com/fedor-metsger/ter-homeworks/blob/5dc4716c536fc23c134d9d1502c4fdd58529f0ac/04/src/variables.tf#L49).
   
   Результат проверки:
   
   ![](https://github.com/fedor-metsger/devops-netology/blob/main/Screenshot%20at%202023-06-04%2017-21-48.png)

   
