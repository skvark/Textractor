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
        {"ara", "Arabic"},
        {"afr", "Afrikaans"},
        {"bul", "Bulgarian"},
        {"ben", "Bengali"},
        {"bel", "Belarusian"},
        {"cat", "Catalan"},
        {"ces", "Czech"},
        {"chi_sim", "Chinese (Simplified)"},
        {"chi_tra", "Chinese (Traditional)"},
        {"chr", "Cherokee"},
        {"dan", "Danish"},
        {"deu", "German"},
        {"ell", "Greek"},
        {"eng", "English"},
        {"epo", "Esperanto"},
        {"eus", "Basque"},
        {"est", "Estonian"},
        {"equ", "Math / equation detection"},
        {"enm", "Middle English (1100-1500)"},
        {"fin", "Finnish"},
        {"fra", "French"},
        {"frm", "Middle French (ca. 1400-1600)"},
        {"frk", "Frankish"},
        {"grc", "Ancient Greek"},
        {"glg", "Galician"},
        {"hun", "Hungarian"},
        {"hrv", "Croatian"},
        {"hin", "Hindi"},
        {"heb", "Hebrew"},
        {"ind", "Indonesian"},
        {"isl", "Icelandic"},
        {"ita", "Italian"},
        {"jpn", "Japanese"},
        {"kan", "Kannada"},
        {"kor", "Korean"},
        {"lav", "Latvian"},
        {"lit", "Lithuanian"},
        {"msa", "Malay"},
        {"mlt", "Maltese"},
        {"mkd", "Macedonian"},
        {"mal", "Malayalam"},
        {"nld", "Dutch"},
        {"nor", "Norwegian"},
        {"pol", "Polish"},
        {"por", "Portuguese"},
        {"ron", "Romanian"},
        {"rus", "Russian"},
        {"slk", "Slovakian"},
        {"slv", "Slovenian"},
        {"spa", "Spanish"},
        {"sqi", "Albanian"},
        {"srp", "Serbian"},
        {"swa", "Swahili"},
        {"swe", "Swedish"},
        {"tam", "Tamil"},
        {"tel", "Telugu"},
        {"tgl", "Tagalog"},
        {"tha", "Thai"},
        {"tur", "Turkish"},
        {"ukr", "Ukrainian"},
        {"vie", "Vietnamese"},
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
