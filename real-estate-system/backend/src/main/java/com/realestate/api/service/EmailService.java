package com.realestate.api.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    @Async
    public void sendActivationEmail(String to, String prenom, String activationUrl) {
        try {
            var message = mailSender.createMimeMessage();
            var helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setTo(to);
            helper.setSubject("Activez votre compte Horoazhon");
            helper.setText(buildActivationHtml(prenom, activationUrl), true);

            mailSender.send(message);
            log.info("Activation email sent to {}", to);
        } catch (Exception e) {
            log.error("Failed to send activation email to {}: {}", to, e.getMessage());
        }
    }

    private String buildActivationHtml(String prenom, String activationUrl) {
        return """
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                    <div style="background: #1e293b; color: white; padding: 2rem; text-align: center;">
                        <h1 style="margin: 0;">Horoazhon</h1>
                    </div>
                    <div style="padding: 2rem; background: #f8fafc;">
                        <p>Bonjour <strong>%s</strong>,</p>
                        <p>Un compte a ete cree pour vous sur la plateforme Horoazhon.</p>
                        <p>Cliquez sur le bouton ci-dessous pour activer votre compte et choisir votre mot de passe :</p>
                        <div style="text-align: center; margin: 2rem 0;">
                            <a href="%s"
                               style="background: #3b82f6; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: bold;">
                                Activer mon compte
                            </a>
                        </div>
                        <p style="color: #64748b; font-size: 0.85rem;">Ce lien expire dans 7 jours.</p>
                        <p style="color: #64748b; font-size: 0.85rem;">Si le bouton ne fonctionne pas, copiez ce lien dans votre navigateur :<br>
                        <a href="%s" style="color: #3b82f6;">%s</a></p>
                    </div>
                </div>
                """.formatted(prenom, activationUrl, activationUrl, activationUrl);
    }
}
