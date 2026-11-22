import { flushPromises, mount } from '@vue/test-utils'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import App from '../../src/App.vue'

const api = vi.hoisted(() => ({
  getProfile: vi.fn(),
  getProjects: vi.fn(),
  sendContact: vi.fn(),
}))

vi.mock('../../src/api', () => api)

describe('Portafolio', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    api.getProfile.mockResolvedValue({ name: 'Wendy Ramírez', role: 'Estudiante de Ingeniería de Sistemas', location: 'Sucre', intro: 'Hola.' })
    api.getProjects.mockResolvedValue([{ title: 'Proyecto de prueba', category: 'Web', description: 'Descripción', tags: ['Vue'] }])
  })

  it('muestra el nombre recibido desde la API', async () => {
    const wrapper = mount(App)
    await flushPromises()
    expect(wrapper.text()).toContain('Wendy Ramírez')
  })

  it('muestra proyectos recibidos desde la API', async () => {
    const wrapper = mount(App)
    await flushPromises()
    expect(wrapper.text()).toContain('Proyecto de prueba')
    expect(wrapper.text()).toContain('Vue')
  })

  it('envía el formulario y limpia los campos al completarse', async () => {
    api.sendContact.mockResolvedValue({ id: 1, message: 'Mensaje enviado.' })
    const wrapper = mount(App)
    await flushPromises()
    await wrapper.get('input[name="name"]').setValue('Mitsu')
    await wrapper.get('input[name="email"]').setValue('mitsu@example.com')
    await wrapper.get('textarea[name="message"]').setValue('Hola, quiero conversar sobre un proyecto.')
    await wrapper.get('form').trigger('submit')
    await flushPromises()
    expect(api.sendContact).toHaveBeenCalledWith({ name: 'Mitsu', email: 'mitsu@example.com', message: 'Hola, quiero conversar sobre un proyecto.' })
    expect(wrapper.text()).toContain('Mensaje enviado.')
    expect((wrapper.get('input[name="name"]').element as HTMLInputElement).value).toBe('')
  })
})
