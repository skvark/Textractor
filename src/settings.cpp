#include "settings.h"
#include <QDir>

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
    setTileSize(200);
    setMinCount(50);
    setBgVal(255);
    setScoreFract(0.09);
    setSmoothingFactor(0);
    setThreshold(100);
    setConfidence(20);
    settings_->sync();
}

void SettingsManager::setLanguage(QString language)
{
    if(!language.isEmpty()) {
        settings_->setValue("language", toQVariant(languages.key(language)));
    }
}

QString SettingsManager::getLanguageCode()
{
    return settings_->value("language").toString();
}

QString SettingsManager::getLanguageCode(QString language)
{
    return languages.key(language);
}


QStringList SettingsManager::getLanguageList()
{
    QStringList langs;
    QStringList langs2;

    // Yeah, not very efficient but
    // the list is short enough for this
    foreach(QString lang, langs_) {
        if(isLangDataAvailable(lang)) {
            langs.append(lang);
        } else {
            langs2.append(lang);
        }
    }

    langs.sort();
    langs2.sort();

    langs_ = langs + langs2;

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

void SettingsManager::setTileSize(int size)
{
    settings_->setValue("tilesize", toQVariant(size));
}

int SettingsManager::getTileSize()
{
    return settings_->value("tilesize").toInt();
}

void SettingsManager::setSmoothingFactor(int factor)
{
    settings_->setValue("factor", toQVariant(factor));
}

int SettingsManager::getSmoothingFactor()
{
    return settings_->value("factor").toInt();
}

void SettingsManager::setThreshold(int treshold)
{
    settings_->setValue("threshold", toQVariant(treshold));
}

int SettingsManager::getThreshold()
{
    return settings_->value("threshold").toInt();
}

void SettingsManager::setMinCount(int mincount)
{
    settings_->setValue("mincount", toQVariant(mincount));
}

int SettingsManager::getMinCount()
{
    return settings_->value("mincount").toInt();
}

void SettingsManager::setBgVal(int bgval)
{
    settings_->setValue("bgval", toQVariant(bgval));
}

int SettingsManager::getBgVal()
{
    return settings_->value("bgval").toInt();
}

void SettingsManager::setScoreFract(float scorefract)
{
    settings_->setValue("scorefract", toQVariant(scorefract));
}

float SettingsManager::getScoreFract()
{
    return settings_->value("scorefract").toDouble();
}

void SettingsManager::setConfidence(int confidence)
{
    settings_->setValue("confidence", toQVariant(confidence));
}

float SettingsManager::getConfidence()
{
    return settings_->value("confidence").toDouble();
}

bool SettingsManager::isLangDataAvailable(QString lang)
{
    QString datadir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QDir tessdata = QDir(datadir + "/tesseract-ocr/tessdata/");
    QStringList data = tessdata.entryList();
    return data.contains(languages.key(lang) + QString(".traineddata"));
}
