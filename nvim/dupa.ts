import { env } from '$env/dynamic/private';
import { Resend } from 'resend';
import { fail } from '@sveltejs/kit';
import type { Actions } from './$types';

export const actions: Actions = {
	default: async ({ request }) => {
		const formData = await request.formData();

		const name = formData.get('name')?.toString().trim();
		const company = formData.get('company')?.toString().trim();
		const email = formData.get('email')?.toString().trim();
		const phone = formData.get('phone')?.toString().trim();
		const subject = formData.get('subject')?.toString().trim();
		const message = formData.get('message')?.toString().trim();
		const rodoBasic = formData.get('rodo-basic') === 'on';
		const rodoMarketing = formData.get('rodo-marketing') === 'on';

		// Validation
		if (!name) {
			return fail(400, {
				error: 'Imię i nazwisko jest wymagane.',
				name,
				company,
				email,
				phone,
				subject,
				message
			});
		}

		if (!email) {
			return fail(400, {
				error: 'Adres e-mail jest wymagany.',
				name,
				company,
				email,
				phone,
				subject,
				message
			});
		}

		const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
		if (!emailRegex.test(email)) {
			return fail(400, {
				error: 'Podaj prawidłowy adres e-mail.',
				name,
				company,
				email,
				phone,
				subject,
				message
			});
		}

		if (!rodoBasic) {
			return fail(400, {
				error: 'Wymagana jest zgoda na przetwarzanie danych.',
				name,
				company,
				email,
				phone,
				subject,
				message
			});
		}

		// Check for required environment variables
		if (!env.RESEND_API_KEY || !env.CONTACT_EMAIL) {
			console.error('Missing required environment variables: RESEND_API_KEY or CONTACT_EMAIL');
			return fail(500, {
				error: 'Konfiguracja serwera jest nieprawidłowa. Skontaktuj się z administratorem.'
			});
		}

		// Build email content
		const htmlContent = `
			<h2>Nowe zapytanie z formularza kontaktowego MCStore</h2>
			<table style="border-collapse: collapse; width: 100%; max-width: 600px;">
				<tr>
					<td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">Imię i nazwisko</td>
					<td style="padding: 8px; border: 1px solid #ddd;">${escapeHtml(name)}</td>
				</tr>
				<tr>
					<td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">Firma</td>
					<td style="padding: 8px; border: 1px solid #ddd;">${escapeHtml(company || '-')}</td>
				</tr>
				<tr>
					<td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">E-mail</td>
					<td style="padding: 8px; border: 1px solid #ddd;"><a href="mailto:${escapeHtml(email)}">${escapeHtml(email)}</a></td>
				</tr>
				<tr>
					<td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">Telefon</td>
					<td style="padding: 8px; border: 1px solid #ddd;">${escapeHtml(phone || '-')}</td>
				</tr>
				<tr>
					<td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">Temat</td>
					<td style="padding: 8px; border: 1px solid #ddd;">${escapeHtml(subject || '-')}</td>
				</tr>
				<tr>
					<td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">Wiadomość</td>
					<td style="padding: 8px; border: 1px solid #ddd;">${escapeHtml(message || '-').replace(/\n/g, '<br>')}</td>
				</tr>
				<tr>
					<td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">Zgoda RODO</td>
					<td style="padding: 8px; border: 1px solid #ddd;">Tak</td>
				</tr>
				<tr>
					<td style="padding: 8px; border: 1px solid #ddd; font-weight: bold;">Zgoda na marketing</td>
					<td style="padding: 8px; border: 1px solid #ddd;">${rodoMarketing ? 'Tak' : 'Nie'}</td>
				</tr>
			</table>
		`;

		try {
			const resend = new Resend(env.RESEND_API_KEY);
			const fromAddress = env.RESEND_FROM_EMAIL || 'MCStore <onboarding@resend.dev>';
			const { error } = await resend.emails.send({
				from: fromAddress,
				to: env.CONTACT_EMAIL,
				replyTo: email,
				subject: `[MCStore] ${subject || 'Nowe zapytanie'} - ${name}`,
				html: htmlContent
			});

			if (error) {
				console.error('Resend error:', error);
				return fail(500, {
					error: 'Wystąpił błąd podczas wysyłania wiadomości. Spróbuj ponownie później.'
				});
			}

			return { success: true };
		} catch (err) {
			console.error('Error sending email:', err);
			return fail(500, {
				error: 'Wystąpił błąd podczas wysyłania wiadomości. Spróbuj ponownie później.'
			});
		}
	}
};

function escapeHtml(text: string): string {
	const map: Record<string, string> = {
		'&': '&amp;',
		'<': '&lt;',
		'>': '&gt;',
		'"': '&quot;',
		"'": '&#039;'
	};
	return text.replace(/[&<>"']/g, (char) => map[char]);
}
