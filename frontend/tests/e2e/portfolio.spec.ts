import { expect, test } from '@playwright/test'

test('presenta el portafolio y el perfil', async ({ page }) => {
  await page.goto('/')
  await expect(page.getByRole('heading', { name: /Ideas que se vuelven experiencias/i })).toBeVisible()
  await expect(page.getByText('Wendy Ramírez', { exact: false }).first()).toBeVisible()
})

test('permite navegar a la selección de proyectos', async ({ page }) => {
  await page.goto('/')
  await page.getByRole('link', { name: /Explorar proyectos/i }).click()
  await expect(page).toHaveURL(/#proyectos$/)
  await expect(page.getByRole('heading', { name: /Hecho con intención/i })).toBeVisible()
  await expect(page.getByRole('heading', { name: 'El despertar del bosque' })).toBeVisible()
})

test('envía el formulario de contacto y confirma el resultado', async ({ page }) => {
  await page.goto('/')
  await page.getByLabel('Tu nombre').fill('Visitante E2E')
  await page.getByLabel('Tu correo').fill(`e2e-${Date.now()}@example.com`)
  await page.getByLabel('Cuéntame un poco').fill('Hola, quisiera conversar sobre una colaboración.')
  await page.getByRole('button', { name: /Enviar mensaje/i }).click()
  await expect(page.getByRole('status').last()).toHaveText('¡Gracias! Tu mensaje fue enviado.')
})
