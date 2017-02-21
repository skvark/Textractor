#ifndef SETTINGS_H
#define SETTINGS_H

#include <QCoreApplication>
#include <QStandardPaths>
#include <QDir>
#include <QSettings>
#include <QString>
#include <QList>
#include <QStringList>
#include <QVariantList>
#include <QDebug>
#include <QMap>

namespace {

    const QMap<QString, QString> languages {
        {"aze", "Azerbaijani"},
        {"aze_cyrl", "Azerbaijani - Cyrilic"},
        {"ara", "Arabic"},
        {"afr", "Afrikaans"},
        {"amh", "Amharic"},
        {"asm", "Assamese"},
        {"bul", "Bulgarian"},
        {"bod", "Tibetan"},
        {"bos", "Bosnian"},
        {"ben", "Bengali"},
        {"bel", "Belarusian"},
        {"cat", "Catalan; Valencian"},
        {"ces", "Czech"},
        {"ceb", "Cebuano"},
        {"chi_sim", "Chinese (Simplified)"},
        {"chi_tra", "Chinese (Traditional)"},
        {"chr", "Cherokee"},
        {"cym", "Welsh"},
        {"dan", "Danish"},
        {"deu", "German"},
        {"dzo", "Dzongkha"},
        {"ell", "Greek, Modern (1453-)"},
        {"eng", "English"},
        {"epo", "Esperanto"},
        {"eus", "Basque"},
        {"est", "Estonian"},
        {"equ", "Math / equation detection"},
        {"enm", "English, Middle (1100-1500)"},
        {"fin", "Finnish"},
        {"fas", "Persian"},
        {"fra", "French"},
        {"frm", "French, Middle (ca. 1400-1600)"},
        {"frk", "Frankish"},
        {"grc", "Greek, Ancient (-1453)"},
        {"gle", "Irish"},
        {"glg", "Galician"},
        {"guj", "Gujarati"},
        {"hat", "Haitian; Haitian Creole"},
        {"hun", "Hungarian"},
        {"hrv", "Croatian"},
        {"hin", "Hindi"},
        {"heb", "Hebrew"},
        {"ind", "Indonesian"},
        {"isl", "Icelandic"},
        {"ita", "Italian"},
        {"ita_old", "Italian - Old"},
        {"iku", "Inuktitut"},
        {"jpn", "Japanese"},
        {"jav", "Javanese"},
        {"kan", "Kannada"},
        {"kat", "Georgian"},
        {"kat_old", "Georgian - Old"},
        {"kaz", "Kazakh"},
        {"kir", "Kirghiz; Kyrgyz"},
        {"khm", "Central Khmer"},
        {"kor", "Korean"},
        {"kur", "Kurdish"},
        {"lav", "Latvian"},
        {"lat", "Latin"},
        {"lao", "Lao"},
        {"lit", "Lithuanian"},
        {"msa", "Malay"},
        {"mlt", "Maltese"},
        {"mkd", "Macedonian"},
        {"mal", "Malayalam"},
        {"mar", "Marathi"},
        {"mya", "Burmese"},
        {"nld", "Dutch; Flemish"},
        {"nep", "Nepali"},
        {"nor", "Norwegian"},
        {"ori", "Oriya"},
        {"pan", "Panjabi; Punjabi"},
        {"pol", "Polish"},
        {"por", "Portuguese"},
        {"pus", "Pushto; Pashto"},
        {"ron", "Romanian; Moldavian; Moldovan"},
        {"rus", "Russian"},
        {"san", "Sanskrit"},
        {"sin", "Sinhala; Sinhalese"},
        {"slk", "Slovak"},
        {"slv", "Slovenian"},
        {"spa", "Spanish; Castilian"},
        {"spa_old", "Spanish; Castilian - Old"},
        {"sqi", "Albanian"},
        {"srp", "Serbian"},
        {"srp_latn", "Serbian - Latin"},
        {"swa", "Swahili"},
        {"swe", "Swedish"},
        {"syr", "Syriac"},
        {"tam", "Tamil"},
        {"tel", "Telugu"},
        {"tgk", "Tajik"},
        {"tgl", "Tagalog"},
        {"tir", "Tigrinya"},
        {"tha", "Thai"},
        {"tur", "Turkish"},
        {"uig", "Uighur; Uyghur"},
        {"ukr", "Ukrainian"},
        {"urd", "Urdu"},
        {"uzb", "Uzbek"},
        {"uzb_cyrl", "Uzbek - Cyrilic"},
        {"vie", "Vietnamese"},
        {"yid", "Yiddish"}
    };

}

class SettingsManager : public QObject
{
    Q_OBJECT

public:
    SettingsManager(QObject *parent = 0);
    ~SettingsManager();

    Q_INVOKABLE void resetToDefaults();

    // language settings

    Q_INVOKABLE void setLanguage(QString language);
    Q_INVOKABLE QString getLanguage();
    Q_INVOKABLE int getLangIndex();
    Q_INVOKABLE QString getLanguageCode();
    Q_INVOKABLE QString getLanguageCode(QString language);
    Q_INVOKABLE QStringList getLanguageList();

    // image processing settings

    Q_INVOKABLE void setTileSize(int size);
    Q_INVOKABLE int getTileSize();

    Q_INVOKABLE void setSmoothingFactor(int factor);
    Q_INVOKABLE int getSmoothingFactor();

    Q_INVOKABLE void setThreshold(int treshold);
    Q_INVOKABLE int getThreshold();

    Q_INVOKABLE void setMinCount(int mincount);
    Q_INVOKABLE int getMinCount();

    Q_INVOKABLE void setBgVal(int bgval);
    Q_INVOKABLE int getBgVal();

    Q_INVOKABLE void setScoreFract(float scorefract);
    Q_INVOKABLE float getScoreFract();

    Q_INVOKABLE void setConfidence(int confidence);
    Q_INVOKABLE float getConfidence();

    Q_INVOKABLE bool isLangDataAvailable(QString lang);

signals:
    void reset();

private:

    template <typename T>
    QVariant toQVariant(const T value)
    {
        return QVariant::fromValue(value);
    }

    QSettings *settings_;
    QStringList langs_;
};

#endif // SETTINGS_H
