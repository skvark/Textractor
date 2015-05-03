#include "settings.h"

SettingsManager::SettingsManager(QObject *parent) :
    QObject(parent)
{
    QString data_dir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QSettings::setPath(QSettings::NativeFormat, QSettings::UserScope, data_dir);
    settings_ = new QSettings;
    settings_->setIniCodec("UTF-8");
    foreach(QString value, languages) {
        langs_.append(value);
    }
    langs_.sort();
}

SettingsManager::~SettingsManager() {
    delete settings_;
    settings_ = 0;
}

void SettingsManager::resetToDefaults()
{
    return;
}

void SettingsManager::setLanguage(QString language)
{
    QVariant data;
    if(!language.isEmpty()) {
        data = QVariant::fromValue(languages.key(language));
        settings_->setValue("language", data);
        settings_->sync();
    }
}

QString SettingsManager::getLanguageCode()
{
    return settings_->value("language").toString();
}

QStringList SettingsManager::getLanguageList()
{
    return langs_;
}

QString SettingsManager::getLanguage()
{
    return languages.value(settings_->value("language").toString());
}

int SettingsManager::getLangIndex()
{
    return langs_.indexOf(getLanguage());
}
