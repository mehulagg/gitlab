import Vue from 'vue';
import UserAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';

describe('User Avatar Link Component', function () {
  beforeEach(function () {
    this.propsData = {
      linkHref: 'myavatarurl.com',
      imgSize: 99,
      imgSrc: 'myavatarurl.com',
      imgAlt: 'mydisplayname',
      imgCssClasses: 'myextraavatarclass',
      tooltipText: 'tooltip text',
      tooltipPlacement: 'bottom',
    };

    const UserAvatarLinkComponent = Vue.extend(UserAvatarLink);

    this.userAvatarLink = new UserAvatarLinkComponent({
      propsData: this.propsData,
    }).$mount();

    this.userAvatarImage = this.userAvatarLink.$children[0];
  });

  it('should return a defined Vue component', function () {
    expect(this.userAvatarLink).toBeDefined();
  });

  it('should have user-avatar-image registered as child component', function () {
    expect(this.userAvatarLink.$options.components.userAvatarImage).toBeDefined();
  });

  it('user-avatar-link should have user-avatar-image as child component', function () {
    expect(this.userAvatarImage).toBeDefined();
  });

  it('should render <a> as a child element', function () {
    const componentLinkTag = this.userAvatarLink.$el.outerHTML;
    expect(componentLinkTag).toContain('<a');
  });

  it('should have <img> as a child element', function () {
    const componentImgTag = this.userAvatarLink.$el.outerHTML;
    expect(componentImgTag).toContain('<img');
  });

  it('should return neccessary props as defined', function () {
    _.each(this.propsData, (val, key) => {
      expect(this.userAvatarLink[key]).toBeDefined();
    });
  });

  it('should include props in the rendered output', function () {
    _.each(this.propsData, (val) => {
      expect(this.userAvatarLink.$el.outerHTML).toContain(val);
    });
  });
});
